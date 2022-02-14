//
//  RegisterFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/09.
//

import UIKit
import RxFlow
import Then

class RegisterFlow: Flow {
    
    let rootViewController: UINavigationController
    let initialViewController: IDInputViewController

    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    init(services: AppServices) {
        self.services = services
        
        // Present 하자마자 바로 보여줘야 하기 때문에 미리 NavController의 rootVC 정의
        
        let reactor = IDInputViewReactor(userService: services.userService)
        let idInputVC = IDInputViewController(reactor: reactor)
        
        self.initialViewController = idInputVC
        
        self.rootViewController = UINavigationController(rootViewController: self.initialViewController)
        self.rootViewController.modalPresentationStyle = .overFullScreen
        self.rootViewController.navigationBar.tintColor = .black
    }
     
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ RegisterFlow step: \(step)")
        switch step {
            
        case .registerIsRequired:
            return navigateToIdInputView()
            
        case .idInputIsCompleted:
            return navigateToPasswordInputView()
            
        case .passwordInputIsCompleted:
            return navigateToNicknameInputView()
      
        case .nicknameInputIsCompleted:
            return navigateToEmailInputView()
       
        case .emailInputIsCompleted:
            return presentCongratulateUserView()
            
        case .mainIsRequired:
            return .end(forwardToParentFlowWithStep: AppStep.mainIsRequired)
            
        case .termsAndConditionIsRequired:
            return presentTermsAndConditionsView()
            
        case .privacyTermsIsRequired:
            return presentPrivacyTermsView()
            
        case .loginIsRequired:
            return .end(forwardToParentFlowWithStep: AppStep.loginIsRequired)
            
        default:
            return .none
        }
    }
}

extension RegisterFlow {
    
    private func navigateToIdInputView() -> FlowContributors {
    
        return .one(flowContributor: .contribute(
            withNextPresentable: self.initialViewController,
            withNextStepper: self.initialViewController.reactor!)
        )
    }
    
    private func navigateToPasswordInputView() -> FlowContributors {
        
        let reactor = PasswordInputViewReactor()
        let vc = PasswordInputViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToNicknameInputView() -> FlowContributors {
        
        let reactor = NickNameInputViewReactor(userService: services.userService)
        let vc = NickNameInputViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToEmailInputView() -> FlowContributors {
        
        let reactor = EmailForLostPasswordViewReactor(userService: services.userService)
        let vc = EmailForLostPasswordViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func presentCongratulateUserView() -> FlowContributors {
        
        let reactor = CongratulateUserViewReactor(userService: services.userService)
        let vc = CongratulateUserViewController(reactor: reactor)
        vc.modalPresentationStyle = .fullScreen
        
        self.rootViewController.present(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }

    private func presentTermsAndConditionsView() -> FlowContributors {
        let url = URL(string: K.URL.termsAndConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
    
    private func presentPrivacyTermsView() -> FlowContributors {
        let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
}
