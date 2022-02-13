//
//  SettingsFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/08.
//

import Foundation
import RxSwift
import RxFlow

class AccountManagementFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: AccountManagementViewController
    
    init(services: AppServices) {
        self.services = services
        
        let reactor = AccountManagementViewReactor(userDefaultsGenericService: services.userDefaultsGenericService)
        let accountVC = AccountManagementViewController(reactor: reactor)
        self.rootViewController = accountVC
        
    }
    
    func adapt(step: Step) -> Single<Step> {
        guard let step = step as? AppStep else { return .just(step) }
        
        switch step {
        case .unRegisterIsRequired:
            
            let joinedChatRoomPids: [String] = self.services.userDefaultsGenericService.get(key: UserDefaults.Keys.joinedChatRoomPIDs) ?? []
            
            /// 유저가 참여하고 있는 공구가 있는지 판별  -> 있으면 주의사항 먼저 읽게 해야함
            return joinedChatRoomPids.count == 0
            ? .just(step)
            : .just(AppStep.readingFirstPrecautionsIsRequired)
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ AccountManagementFlow step: \(step)")
        switch step {
        case .accountManagementIsRequired:
            return navigateToAccountManagementVC()
            
        case .changeIdIsRequired:
            return navigateToChangeId()
            
        case .changeNicknameIsRequired:
            return navigateToChangeNickname()
            
        case .changePasswordIsRequired:
            return navigateToChangePassword()
            
        case .changeEmailIsRequired:
            return navigateToChangeEmailForPasswordLoss()
            
        case .logOutIsRequired:
            return navigateToLoginFlow()
            
        case .unRegisterIsRequired:
            return navigateToUnregisterFlow()
            
        case .readingFirstPrecautionsIsRequired:
            return navigateToReadPrecautionsFirst()
            
        default:
            return .none
        }
    }
}

extension AccountManagementFlow {
    
    private func navigateToAccountManagementVC() -> FlowContributors {
        rootViewController.hidesBottomBarWhenPushed = true
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func navigateToChangeId() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeIdVC = ChangeIdViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(changeIdVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeIdVC, withNextStepper: reactor))
    }
    
    private func navigateToChangeNickname() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeNicknameVC = ChangeNicknameViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(changeNicknameVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeNicknameVC, withNextStepper: reactor))
    }
    
    private func navigateToChangePassword() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changePasswordVC = ChangePasswordViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(changePasswordVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changePasswordVC, withNextStepper: reactor))
    }
    
    private func navigateToChangeEmailForPasswordLoss() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeEmailVC = ChangeEmailForPasswordLossViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(changeEmailVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeEmailVC, withNextStepper: reactor))
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
    
    // 곧바로 비밀번호 확인 화면으로 이동
    private func navigateToUnregisterFlow() -> FlowContributors {
        
        let reactor = UnregisterViewReactor(userService: self.services.userService)
        let inputPasswordVC = UnregisterUser_InputPasswordViewController(reactor: reactor)

        let unregisterFlow = UnregisterFlow(services: services, viewController: inputPasswordVC)
        
        Flows.use(unregisterFlow, when: .created) { [unowned self] root in
            self.rootViewController.navigationController?.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: unregisterFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.passwordForUnregisterIsRequired(previousVCType: .inputPassword)))
        )
    }
    
    // 공구가 존재할 때 -> 미리 주의사항 읽을 수 있는 화면으로 이동
    private func navigateToReadPrecautionsFirst() -> FlowContributors {
        
        /// 너무 간단한 화면이라 별도 Reactor를 두지 않고 VC가 Stepper 역할 수행
        let firstPrecautionVC = UnregisterUser_CheckFirstPrecautionsViewController()
        
        let unregisterFlow = UnregisterFlow(services: services, viewController: firstPrecautionVC)
        
        Flows.use(unregisterFlow, when: .created) { [unowned self] root in
            self.rootViewController.navigationController?.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: unregisterFlow,
            withNextStepper: firstPrecautionVC)
        )
    }
}
