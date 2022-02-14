//
//  UnregisterFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/11.
//

import Foundation
import RxFlow

class UnregisterFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        
        switch self.rootViewController.unregisterStep {
            
        case .readPrecautionsFirst:
            guard let rootVC = self.rootViewController as? UnregisterUser_CheckFirstPrecautionsViewController
            else { fatalError() }
            return rootVC
        
        case .inputPassword:
            guard let rootVC = self.rootViewController as? UnregisterUser_InputPasswordViewController
            else { fatalError() }
            return rootVC
        }
    }
    
    private let rootViewController: UnregisterViewType
    
    init(services: AppServices, viewController: UnregisterViewType) {
        self.services = services
        self.rootViewController = viewController
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ Unregister Flow step: \(step)")
        switch step {
            
        case .readingFirstPrecautionsIsRequired:
            return navigateToCheckFirstPrecautionsView()
            
        case .readingSecondPrecautionsIsRequired:
            return navigateToCheckSecondPrecautionsView()
            
        case .passwordForUnregisterIsRequired(let previousVCType):
            return navigateToInputPasswordViewForUnregister(previousVCType: previousVCType)
            
        case .inputSuggestionForUnregisterIsRequired:
            return navigateToInputSuggestionViewForUnregister()
            
        case .kakaoHelpChannelLinkIsRequired:
            return openKakaoHelpChannelLink()
            
        case .unregisterIsCompleted:
            return navigateToLoginFlow()
            
        default:
            return .none
        }
    }
}

extension UnregisterFlow {
    
    private func navigateToCheckFirstPrecautionsView() -> FlowContributors {
        
        let vc = UnregisterUser_CheckFirstPrecautionsViewController()
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: vc)
        )
    }
        
    private func navigateToCheckSecondPrecautionsView() -> FlowContributors {
        
        let vc = UnregisterUser_CheckSecondPrecautionsViewController()
        
        guard let rootVC = self.rootViewController as? UnregisterUser_CheckFirstPrecautionsViewController else { return .none }
        
        rootVC.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: vc)
        )
    }
    
    private func navigateToInputPasswordViewForUnregister(previousVCType: UnregisterStepType) -> FlowContributors {
        
        switch previousVCType {
            
        case .readPrecautionsFirst:
            
            guard let rootVC = self.rootViewController as? UnregisterUser_CheckFirstPrecautionsViewController else { return .none }
            
            let reactor = UnregisterViewReactor(userService: services.userService)
            let nextVC = UnregisterUser_InputPasswordViewController(reactor: reactor)
            
            rootVC.navigationController?.pushViewController(nextVC, animated: true)
            
            return .one(flowContributor: .contribute(
                withNextPresentable: nextVC,
                withNextStepper: reactor)
            )
            
        case .inputPassword:
            
            guard let rootVC = self.rootViewController as? UnregisterUser_InputPasswordViewController else { return .none }
            
            return .one(flowContributor: .contribute(
                withNextPresentable: rootVC,
                withNextStepper: rootVC.reactor!)
            )
        }
    }
    
    private func navigateToInputSuggestionViewForUnregister() -> FlowContributors {
        
        let reactor = UnregisterViewReactor(userService: self.services.userService)
        let vc = UnregisterUser_InputSuggestionViewController(reactor: reactor)
        
        guard let rootVC = self.rootViewController as? UnregisterUser_InputPasswordViewController else { return .none }
        
        rootVC.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func openKakaoHelpChannelLink() -> FlowContributors {
        let url = URL(string: K.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
        return .none
    }
    
    private func navigateToLoginFlow() -> FlowContributors {
        self.services.userDefaultsGenericService.resetAllUserInfo()
        
        let loginFlow = LoginFlow(services: services)
        
        Flows.use(loginFlow, when: .created) { root in
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(root)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.loginIsRequired)
        ))
    }
}
