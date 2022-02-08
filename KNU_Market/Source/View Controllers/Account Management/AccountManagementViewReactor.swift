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
        case changeId
        case changeNickname
        case changePassword
        case changeEmailForPasswordLoss
        case logout
        case unregister
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    init(userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.userDefaultsGenericService = userDefaultsGenericService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .changeId:
            self.steps.accept(AppStep.changeIdIsRequired)
            return .empty()
            
        case .changeNickname:
            self.steps.accept(AppStep.changeNicknameIsRequired)
            return .empty()
            
        case .changePassword:
            self.steps.accept(AppStep.changePasswordIsRequired)
            return .empty()
            
        case .changeEmailForPasswordLoss:
            self.steps.accept(AppStep.changeEmailIsRequired)
            return .empty()
            
        case .logout:
            self.steps.accept(AppStep.logOutIsRequired)
            return .empty()
            
        case .unregister:
            self.steps.accept(AppStep.unRegisterIsRequired)
            return .empty()
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
    
}
