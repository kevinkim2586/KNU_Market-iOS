//
//  MyPageFlo.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import Then
import RxFlow
import UIKit

class MyPageFlow: Flow {

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
        case .myPageIsRequired:
            return navigateToMyPage()
            
        default:
            return .none
        }
    }
}

extension MyPageFlow {
    
    private func navigateToMyPage() -> FlowContributors {
        
        let myPageReactor = MyPageViewReactor(
            userService: services.userService,
            mediaService: services.mediaService,
            userDefaultsGenericService: services.userDefaultsGenericService
        )
        let myPageVC = MyPageViewController(reactor: myPageReactor)
        
        self.rootViewController.pushViewController(myPageVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: myPageVC,
            withNextStepper: myPageReactor)
        )
    }
    
    private func navigateToAccountManagement() -> FlowContributors {
       
        let accountManagementFlow = AccountManagementFlow(services: services)
        
        Flows.use(accountManagementFlow, when: .created) { [unowned self] root in
            self.rootViewController.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: accountManagementFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.accountManagementIsRequired))
        )
    }
}
