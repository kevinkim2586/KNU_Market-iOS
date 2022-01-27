//
//  CongratulateViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/22.
//

import UIKit
import RxSwift
import ReactorKit

final class CongratulateUserViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case goHome
    }
    
    enum Mutation {
        case setLoading(Bool)
        case loginUser(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var isLoggedIn: Bool = false
        var errorMessage: String?
    }
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .goHome:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.userService.login(id: UserRegisterValues.shared.userId, password: UserRegisterValues.shared.password)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(_):
                            return Mutation.loginUser(true)
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
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .loginUser(let isAllowed):
            state.isLoggedIn = isAllowed
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            state.isLoggedIn = false
        }
        return state
    }
}
