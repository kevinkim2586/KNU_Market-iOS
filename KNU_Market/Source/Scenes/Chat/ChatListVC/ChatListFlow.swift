//
//  ChatListFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/14.
//

import Foundation
import RxFlow

class ChatListFlow: Flow {
    
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
//        print("✅ ChatListFlow step: \(step)")
        switch step {
        case .chatListIsRequired:
            return navigateToChatList()
            
        case let .chatIsPicked(roomUid, chatRoomTitle, postUploaderUid, isFirstEntrance, _):
            return navigateToChatFlow(
                roomUid: roomUid,
                roomTitle: chatRoomTitle,
                postUploaderUid: postUploaderUid,
                isFirstEntrance: isFirstEntrance
            )
            
        default: return .none
        }
    }
}

extension ChatListFlow {
    
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
    
    private func navigateToChatFlow(
        roomUid: String,
        roomTitle: String,
        postUploaderUid: String,
        isFirstEntrance: Bool
    ) -> FlowContributors {
        
        let chatFlow = ChatFlow(
            services: services,
            roomUid: roomUid,
            isFirstEntrance: isFirstEntrance,
            roomTitle: roomTitle,
            postUploaderUid: postUploaderUid
        )
            
        Flows.use(chatFlow, when: .created) { [unowned self] root in
            root.hidesBottomBarWhenPushed = true
            self.rootViewController.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.chatIsPicked(roomUid: roomUid, chatRoomTitle: roomTitle, postUploaderUid: postUploaderUid, isFirstEntrance: isFirstEntrance)))
        )
    }
}
