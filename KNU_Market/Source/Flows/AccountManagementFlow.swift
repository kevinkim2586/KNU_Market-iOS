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
    
    private let rootViewController = UINavigationController()
    
    init(services: AppServices) {
        self.services = services
    }
    
    func adapt(step: Step) -> Single<Step> {
        guard let step = step as? AppStep else { return .just(step) }
        
        switch step {
        case .unRegisterIsRequired:
            
            let joinedChatRoomPids: [String] = self.services.userDefaultsGenericService.get(key: UserDefaults.Keys.joinedChatRoomPIDs) ?? []
            
            /// 유저가 참여하고 있는 공구가 있는지 판별  -> 있으면 주의사항 먼저 읽게 해야함
            return joinedChatRoomPids.count == 0
            ? .just(step)
            : .just(AppStep.readingsPrecautionsIsRequired)
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
            
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
            
        case .readingsPrecautionsIsRequired:
            return navigateToReadPrecautionsFirst()
            
        default:
            return .none
        }
    }
}

extension AccountManagementFlow {
    
    private func navigateToAccountManagementVC() -> FlowContributors {
        
        let reactor = AccountManagementViewReactor(userDefaultsGenericService: services.userDefaultsGenericService)
        
        let accountVC = AccountManagementViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(accountVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: accountVC,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToChangeId() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeIdVC = ChangeIdViewController(reactor: reactor)
        self.rootViewController.pushViewController(changeIdVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeIdVC, withNextStepper: reactor))
    }
    
    private func navigateToChangeNickname() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeNicknameVC = ChangeNicknameViewController(reactor: reactor)
        self.rootViewController.pushViewController(changeNicknameVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeNicknameVC, withNextStepper: reactor))
    }
    
    private func navigateToChangePassword() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changePasswordVC = ChangePasswordViewController(reactor: reactor)
        self.rootViewController.pushViewController(changePasswordVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changePasswordVC, withNextStepper: reactor))
    }
    
    private func navigateToChangeEmailForPasswordLoss() -> FlowContributors {
        let reactor = ChangeUserInfoReactor(userService: services.userService)
        let changeEmailVC = ChangeEmailForPasswordLossViewController(reactor: reactor)
        self.rootViewController.pushViewController(changeEmailVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: changeEmailVC, withNextStepper: reactor))
    }
    
    private func navigateToLoginFlow() -> FlowContributors {
        
        self.services.userDefaultsGenericService.resetAllUserInfo()
        
        let loginViewReactor = LoginViewReactor(userService: services.userService)
        let loginVC = LoginViewController(reactor: loginViewReactor)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginVC,
            withNextStepper: loginViewReactor
        ))
    }
    
    private func navigateToReadPrecautionsFirst() -> FlowContributors {
        let firstPrecautionVC = UnregisterUser_CheckFirstPrecautionsViewController()
        self.rootViewController.pushViewController(firstPrecautionVC, animated: true)
        return .none
    }
    
    private func navigateToUnregisterFlow() -> FlowContributors {
        #warning("회원 탈퇴도 하나의 Flow 이니까 추후에 수정")
        let reactor = UnregisterViewReactor(userService: self.services.userService)
        let inputPasswordVC = UnregisterUser_InputPasswordViewController(reactor: reactor)
        self.rootViewController.pushViewController(inputPasswordVC, animated: true)
        return .none
    }
}
