//
//  LoginFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow
import UIKit

class LoginFlow: Flow {
    
    private let rootViewController = UINavigationController()
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    init(services: AppServices) {
        self.services = services
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .loginIsRequired:
            return navigateToLoginScreen()
        default:
            return .none
        }
    }
}

extension LoginFlow {
    
    private func navigateToLoginScreen() -> FlowContributors {
        
        let loginViewReactor = LoginViewReactor(userService: services.userService)
        let loginVC = LoginViewController(reactor: loginViewReactor)
        self.rootViewController.pushViewController(loginVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginVC,
            withNextStepper: loginViewReactor
        ))
    }
}
