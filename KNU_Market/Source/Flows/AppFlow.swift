//
//  AppFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow
import UIKit

class AppFlow: Flow {
    
    private let window: UIWindow
    private let services: AppServices
    
    var root: Presentable {
        return self.window
    }
    
    init(window: UIWindow, services: AppServices) {
        self.window = window
        self.services = services
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ AppFlow step: \(step)")
        switch step {
        case .mainIsRequired:
            return navigateToMainHomeScreen()
            
        case .loginIsRequired:
            return navigateToLoginScreen()
            
        default:
            return .none
        }
    }
}

extension AppFlow {
    
    private func navigateToMainHomeScreen() -> FlowContributors {
        
        let homeFlow = HomeFlow(services: services)
        
        Flows.use(homeFlow, when: .created) { [unowned self] root in
            self.window.rootViewController = root
            self.window.makeKeyAndVisible()
            
            UIView.transition(with: self.window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: homeFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.mainIsRequired))
        )
    }
    
    private func navigateToLoginScreen() -> FlowContributors {
        
        let loginFlow = LoginFlow(services: services)
        
        Flows.use(loginFlow, when: .created) { [unowned self] root in
            self.window.rootViewController = root
            self.window.makeKeyAndVisible()
            
            UIView.transition(with: self.window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.loginIsRequired))
        )
    }
}
