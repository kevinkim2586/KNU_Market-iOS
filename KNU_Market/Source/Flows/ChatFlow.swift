//
//  ChatFlw.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow
import UIKit
import PanModal

class ChatFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    init(services: AppServices) {
        self.services = services
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ ChatFlow step: \(step)")
        switch step {
        case .chatListIsRequired:
            return navigateToChatList()
            
        case let .chatIsPicked(roomUid, chatRoomTitle, postUploaderUid, isFirstEntrance, isFromChatVC):
            
            if isFromChatVC {
                self.rootViewController.popViewController(animated: true)
                return .none
            } else {
                return navigateToChat(
                    roomUid: roomUid,
                    roomTitle: chatRoomTitle,
                    postUploaderUid: postUploaderUid,
                    isFirstEntrance: isFirstEntrance
                )
            }
            
        case let .chatMemberListIsRequired(roomInfo, postUploaderUid):
            
            return presentChatMemberList(roomInfo: roomInfo, postUploaderUid: postUploaderUid)

            
        case .postIsPicked(let postUid, let isFromChatVC):
            return navigateToPost(postUid: postUid, isFromChatVC: isFromChatVC)
            
        case .sendImageOptionsIsRequired:
            return presentSendImageOptionActionSheet()
            
        case let .imageViewIsRequired(url, heroId):
            return presentImageViewController(url: url, heroId: heroId)
            
        case let .alertIsRequired(type, title, message):
            
            return .none
            
            
        case .popViewController:
            self.rootViewController.popViewController(animated: true)
            return .none
            
        case .popViewControllerWithDelay(let seconds):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.rootViewController.popViewController(animated: true)
            }
            return .none
            
        case let .reportIsRequired(userToReport, postUid):
            return presentReportUserView(userToReport: userToReport, postUid: postUid)
            
        case let .safariViewIsRequired(url):
            self.rootViewController.presentSafariView(with: url)
            return .none
            
  
            
        default:
            return .none
        }
    }
}

extension ChatFlow {
    
    private func navigateToChatList() -> FlowContributors {
        
        let chatListReactor = ChatListViewReactor(
            chatListService: services.chatListService,
            userDefaultsGenericService: services.userDefaultsGenericService
        )
        let chatListVC = ChatListViewController(reactor: chatListReactor)
        
        self.rootViewController.pushViewController(chatListVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatListVC,
            withNextStepper: chatListReactor)
        )
    }
    
    private func navigateToChat(
        roomUid: String,
        roomTitle: String,
        postUploaderUid: String,
        isFirstEntrance: Bool
    ) -> FlowContributors {
        
        let chatVM = ChatViewModel(room: roomUid, isFirstEntrance: isFirstEntrance)
        
        let chatVC = ChatViewController(viewModel: chatVM)
        chatVC.roomUID = roomUid
        chatVC.chatRoomTitle = roomTitle
        chatVC.postUploaderUID = postUploaderUid
        chatVC.isFirstEntrance = isFirstEntrance
        chatVC.hidesBottomBarWhenPushed = true
        
        self.rootViewController.pushViewController(chatVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatVC,
            withNextStepper: chatVC)
        )
    }
    
    private func presentChatMemberList(roomInfo: RoomInfo?, postUploaderUid: String) -> FlowContributors {
        
        let chatMemberListVC = ChatMemberListViewController(
            chatManager: ChatManager(),
            roomInfo: roomInfo,
            postUploaderUid: postUploaderUid
        )
        
        self.rootViewController.presentPanModal(chatMemberListVC)
        return .none
    }
    
    private func navigateToPost(postUid: String, isFromChatVC: Bool) -> FlowContributors {
        
        let reactor = PostViewReactor(
            pageId: postUid,
            isFromChatVC: isFromChatVC,
            postService: services.postService,
            chatService: services.chatService,
            sharingService: services.sharingService,
            userDefaultsService: services.userDefaultsGenericService
        )
        
        let postVC = PostViewController(reactor: reactor)
        self.rootViewController.pushViewController(postVC, animated: true)
        
        return .one(flowContributor: .contribute(withNextPresentable: postVC, withNextStepper: reactor))
    }
    
    private func presentSendImageOptionActionSheet() -> FlowContributors {
        
        
        guard let delegateVC = self.rootViewController.visibleViewController
                as? ChatViewController else {
                    return .none
                }
        
        let cameraAction = UIAlertAction(
            title: "사진 찍기",
            style: .default
        ) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = delegateVC
            picker.allowsEditing = true
            self?.rootViewController.present(picker, animated: true)
        }
        let albumAction = UIAlertAction(
            title: "사진 앨범",
            style: .default
        ) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = delegateVC
            picker.allowsEditing = true
            self?.rootViewController.present(picker, animated: true)
        }
     
        let actionSheet = UIHelper.createActionSheet(
            with: [cameraAction, albumAction],
            title: nil
        )
        
        self.rootViewController.present(actionSheet, animated: true)
        
        return .none
    }
    
    private func presentReportUserView(userToReport: String, postUid: String?) -> FlowContributors {
        
        let reportFlow = ReportFlow(
            reportService: self.services.reportService,
            userToReport: userToReport,
            postUid: postUid
        )
        
        Flows.use(reportFlow, when: .created) { [unowned self] rootVC in
            self.rootViewController.present(rootVC, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: reportFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.reportIsRequired(userToReport: userToReport, postUid: postUid)))
        )
    }
    
    private func presentImageViewController(url: URL, heroId: String) -> FlowContributors {
        
        let chatImageVC = ChatImageViewController(imageUrl: url, heroId: heroId)
        chatImageVC.modalPresentationStyle = .overFullScreen
        self.rootViewController.present(chatImageVC, animated: true)
        
        return .none
    }
}
