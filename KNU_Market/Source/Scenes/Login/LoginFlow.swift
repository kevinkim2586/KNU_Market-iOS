//
//  LoginFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import RxFlow
import UIKit

class LoginFlow: Flow {
    
    private let rootViewController: LoginViewController
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    init(services: AppServices) {
        self.services = services
        
        let reactor = LoginViewReactor(userService: services.userService)
        let vc = LoginViewController(reactor: reactor)
        
        self.rootViewController = vc
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ LoginFlow step: \(step)")
        switch step {
        case .loginIsRequired:
            return navigateToLoginScreen()
            
        case .mainIsRequired:
            return navigateToMainHomeScreen()
            
        case .registerIsRequired:
            return navigateToRegisterFlow()
            
        default:
            return .none
        }
    }
}

extension LoginFlow {
    
    private func navigateToLoginScreen() -> FlowContributors {
        
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func navigateToMainHomeScreen() -> FlowContributors {
        
        let homeFlow = HomeFlow(services: services)
        
        Flows.use(homeFlow, when: .created) { rootVC in
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(rootVC)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: homeFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.mainIsRequired))
        )
    }
    
    private func navigateToRegisterFlow() -> FlowContributors {
        
        let registerFlow = RegisterFlow(services: services)
        
        Flows.use(registerFlow, when: .created) { [unowned self] root in
            self.rootViewController.present(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: registerFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.registerIsRequired))
        )
    }
}
