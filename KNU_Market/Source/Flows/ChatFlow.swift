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
            
        case let .chatIsPicked(roomUid, chatRoomTitle, postUploaderUid):
            return navigateToChat(roomUid: roomUid, roomTitle: chatRoomTitle, postUploaderUid: postUploaderUid)
            
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
    
    private func navigateToChat(roomUid: String, roomTitle: String, postUploaderUid: String) -> FlowContributors {
        
        let chatVM = ChatViewModel(room: roomUid, isFirstEntrance: false)
        
        let chatVC = ChatViewController(viewModel: chatVM)
        chatVC.roomUID = roomUid
        chatVC.chatRoomTitle = roomTitle
        chatVC.postUploaderUID = postUploaderUid
        chatVC.hidesBottomBarWhenPushed = true
        
        self.rootViewController.pushViewController(chatVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatVC,
            withNextStepper: chatVM)
        )
    }
}
