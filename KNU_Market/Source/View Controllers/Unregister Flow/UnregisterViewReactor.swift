//
//  UnregisterViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/27.
//

import UIKit
import RxSwift
import ReactorKit

final class UnregisterViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    enum Action {
        case updatePasswordInput(String)
        case tryLoggingIn
    }
    
    enum Mutation {
        case setPassword(String)
        case setLoading(Bool)
        case setErrorMessage(String)
        case setLoginComplete(Bool)
        case setUnregisterComplete(Bool)
    }
    
    struct State {
        var userId: String = User.shared.userID
        var password: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        var loginCompleted: Bool = false
        var unregisterComplete: Bool = false
    }
    
    init(userService: UserServiceType) {
        self.userService = userService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updatePasswordInput(let password):
            return Observable.just(Mutation.setPassword(password))
            
        case .tryLoggingIn:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.userService.login(id: currentState.userId, password: currentState.password)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(_):
                            return Mutation.setLoginComplete(true)
                        case .error(let error):
                            let errorMessage = error == .E101
                            ? "비밀번호가 일치하지 않습니다. 다시 시도해 주세요."
                            : error.errorDescription
                            return Mutation.setErrorMessage(errorMessage)
                        }
                    },
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        switch mutation {
        case .setPassword(let password):
            state.password = password
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setLoginComplete(let isLoggedIn):
            state.loginCompleted = isLoggedIn
            
        case .setUnregisterComplete(let isUnregistered):
            state.unregisterComplete = isUnregistered
        }
        return state
    }
    
}
