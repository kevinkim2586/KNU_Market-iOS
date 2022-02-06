//
//  PostFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import Then
import RxFlow
import UIKit

class PostFlow: Flow {

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
        case .postListIsRequired:
            return navigateToPostList()
            
        default:
            return .none
        }
    }
}

extension PostFlow {
    
    private func navigateToPostList() -> FlowContributors {
        
        let postListReactor = PostListViewReactor(
            postService: services.postService,
            chatListService: services.chatListService,
            userService: services.userService,
            popupService: services.popupService,
            bannerService: services.bannerService,
            userDefaultsGenericService: services.userDefaultsGenericService,
            userNotificationService: services.userNotificationService
        )
        let postListVC = PostListViewController(reactor: postListReactor)
        
        self.rootViewController.pushViewController(postListVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: postListVC,
            withNextStepper: postListReactor)
        )
    }
}
