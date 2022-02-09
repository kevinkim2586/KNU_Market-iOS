//
//  ChatFlw.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow
import UIKit

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
            
            
        case .chatMemberListIsRequired:
            #warning("추후 수정")
            return .none
            
        case .postIsPicked(let postUid, let isFromChatVC):
            return navigateToPost(postUid: postUid, isFromChatVC: isFromChatVC)
            
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
            withNextStepper: chatVM)
        )
    }
    
    private func presentChatMemberList() -> FlowContributors {
        
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
}
