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
        case .verificationOptionIsRequired:
            
            let isUserVerified: Bool = self.services.userDefaultsGenericService.get(key: UserDefaults.Keys.hasVerifiedEmail) ?? false
            
            return isUserVerified
            ? .just(AppStep.popViewController)
            : .just(AppStep.verificationOptionIsRequired)
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {

        guard let step = step as? AppStep else { return .none }
        print("✅ VerificationFlow: \(step)")
        
        switch step {
        case .verificationOptionIsRequired:
            return navigateToVerificationOptions()
            
        case .studentIdGuideIsRequired:
            return navigateToStudentIdGuide()
            
        case .studentIdVerificationIsRequired:
            return navigateToStudentIdVerification()
            
        case .emailVerificationIsRequired:
            return navigateToEmailVerification()
            
        case .checkUserEmailGuideIsRequired(let email):
            return navigateToCheckYourEmail(email: email)
            
        case .userVerificationIsCompleted:
        
            self.rootViewController.navigationController?.popToRootViewController(animated: true)
            return .end(forwardToParentFlowWithStep: AppStep.myPageIsRequired)
            
        case .popViewController:
            
            self.rootViewController.presentCustomAlert(
                title: "인증 회원 안내",
                message: "이미 인증된 회원입니다.\n이제 공동구매를 즐겨보세요!"
            )
            
            self.rootViewController.navigationController?.popViewController(animated: true)
            return .none
            
        default:
            return .none
        }
    }
}

extension VerificationFlow {
    
    private func navigateToVerificationOptions() -> FlowContributors {
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func navigateToStudentIdGuide() -> FlowContributors {
   
        let reactor = StudentIdGuideReactor()
        let vc = StudentIdGuideViewController(reactor: reactor)
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToStudentIdVerification() -> FlowContributors {
        
        let reactor = StudentIdVerificationViewReactor(userService: self.services.userService)
        let vc = StudentIdVerificationViewController(reactor: reactor)
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToEmailVerification() -> FlowContributors {
        
        let reactor = EmailVerificationViewReactor(userService: self.services.userService)
        let vc = EmailVerificationViewController(reactor: reactor)
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToCheckYourEmail(email: String) -> FlowContributors {
        
        let vc = CheckYourEmailViewController(email: email)
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: OneStepper(withSingleStep: AppStep.checkUserEmailGuideIsRequired(email: email)))
        )
    }
}
