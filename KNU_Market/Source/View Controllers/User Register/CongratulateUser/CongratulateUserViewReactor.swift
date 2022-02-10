//
//  CongratulateViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/22.
//

import UIKit
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

final class CongratulateUserViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case goHome
        case goBackToLoginView
        case presentTermsAndConditions
        case presentPrivacyTerms
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setErrorMessage(String)
        case empty
    }
    
    struct State {
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .goHome:
            #warning("수정")
            self.steps.accept(AppStep.mainIsRequired)
            return .empty()
//            return Observable.concat([
//                Observable.just(Mutation.setLoading(true)),
//                self.userService.login(id: UserRegisterValues.shared.userId, password: UserRegisterValues.shared.password)
//                    .asObservable()
//                    .map { result in
//                        switch result {
//                        case .success(_):
//                            self.steps.accept(AppStep.mainIsRequired)
//                            return Mutation.empty
//                        case .error(let error):
//                            return Mutation.setErrorMessage(error.errorDescription)
//                        }
//                    },
//                Observable.just(Mutation.setLoading(false))
//            ])
            
        case .goBackToLoginView:
            self.steps.accept(AppStep.loginIsRequired)
            return .empty()
            
        case .presentTermsAndConditions:
            self.steps.accept(AppStep.termsAndConditionIsRequired)
            return .empty()
            
        case .presentPrivacyTerms:
            self.steps.accept(AppStep.privacyTermsIsRequired)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
        
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        default:
            break
        }
        return state
    }
}
