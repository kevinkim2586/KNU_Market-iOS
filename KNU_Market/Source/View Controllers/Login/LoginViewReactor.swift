//
//  LoginViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/18.
//

import ReactorKit
import UIKit
import Moya

final class LoginViewReactor: Reactor {
    
    let initialState: State
    
    enum Action {
        case updateId(String)
        case updatePassword(String)
        case login
    }
    
    enum Mutation {
        case setId(String)
        case setPassword(String)
        case setLoading(Bool)
        case authorizeUser(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var id: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var isAuthorized: Bool = false
        var errorMessage: String?
    }
    
    let userService: UserServiceType
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateId(let id):
            return Observable.just(Mutation.setId(id))
            
        case .updatePassword(let password):
            return Observable.just(Mutation.setPassword(password))
            
        case .login:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.userService.login(id: currentState.id, password: currentState.password)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(_):
                            return Mutation.authorizeUser(true)
                        case .error(let error):
                            return Mutation.setErrorMessage(error.errorDescription)
                        }
                    },
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setId(let id):
            state.id = id
            state.errorMessage = nil
            
        case .setPassword(let password):
            state.password = password
            state.errorMessage = nil
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .authorizeUser(let isAuthorized):
            state.isAuthorized = isAuthorized
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
}
