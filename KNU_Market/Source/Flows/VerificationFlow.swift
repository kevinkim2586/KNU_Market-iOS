//
//  VerificationFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/08.
//

import Foundation
import RxSwift
import RxFlow

class VerificationFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: VerifyOptionViewController
    
    init(services: AppServices) {
        self.services = services
        
        let verifyOptionVC = VerifyOptionViewController(reactor: VerifyOptionViewReactor())
        self.rootViewController = verifyOptionVC
    }
    
    func adapt(step: Step) -> Single<Step> {
        guard let step = step as? AppStep else { return .just(step) }
        
        switch step {
        case .verificationIsRequired:
            
            let isUserVerified: Bool = self.services.userDefaultsGenericService.get(key: UserDefaults.Keys.hasVerifiedEmail) ?? false
            
            if isUserVerified {
                self.rootViewController.navigationController?.popViewController(animated: true)
            } else {
                return .just(AppStep.verificationIsRequired)
            }
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .verificationIsRequired:
            return navigateToVerificationOptions()
            
            
        default:
            return .none
        }
    }
}

extension VerificationFlow {
    
    private func navigateToVerificationOptions() -> FlowContributors {
        rootViewController.hidesBottomBarWhenPushed = true
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func
}
