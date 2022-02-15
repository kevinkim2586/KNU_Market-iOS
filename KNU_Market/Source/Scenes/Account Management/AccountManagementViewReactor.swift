//
//  AccountManagementViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/08.
//

import Foundation
import RxSwift
import RxRelay
import RxFlow
import ReactorKit

final class AccountManagementViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    enum Action {
        case viewDidLoad
        case viewDidAppear
        case openSystemSettingsApp
        case changeId
        case changeNickname
        case changePassword
        case changeEmailForPasswordLoss
        case logout
        case unregister
    }
    
    enum Mutation {
        case setUserInfo(userId: String, userNickname: String, userEmail: String)
    }
    
    struct State {
        var userId: String = ""
        var userNickname: String = ""
        var userEmailForPasswordLoss: String = ""
    }
    
    init(userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.userDefaultsGenericService = userDefaultsGenericService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .viewDidLoad, .viewDidAppear:
            
            let userId: String = userDefaultsGenericService.get(key: UserDefaults.Keys.username) ?? ""
            let userNickname: String = userDefaultsGenericService.get(key: UserDefaults.Keys.displayName) ?? ""
            let userEmailForPasswordLoss: String = userDefaultsGenericService.get(key: UserDefaults.Keys.emailForPasswordLoss) ?? ""
            
            return Observable.just(Mutation.setUserInfo(
                userId: userId,
                userNickname: userNickname,
                userEmail: userEmailForPasswordLoss)
            )
        case .changeId:
            self.steps.accept(AppStep.changeIdIsRequired)
            
        case .changeNickname:
            self.steps.accept(AppStep.changeNicknameIsRequired)
            
        case .changePassword:
            self.steps.accept(AppStep.changePasswordIsRequired)
            
        case .changeEmailForPasswordLoss:
            self.steps.accept(AppStep.changeEmailIsRequired)
            
        case .logout:
            self.steps.accept(AppStep.logOutIsRequired)
            
        case .unregister:
            self.steps.accept(AppStep.unRegisterIsRequired)
            
        case .openSystemSettingsApp:
            self.steps.accept(AppStep.openSystemSettingsIsRequired)
        }
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        switch mutation {
            
        case let .setUserInfo(userId, userNickname, userEmail):
            state.userId = userId
            state.userNickname = userNickname
            state.userEmailForPasswordLoss = userEmail
        }
        return state
    }
}
