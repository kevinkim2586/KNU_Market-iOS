//
//  EmailVerificationViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/23.
//

import UIKit
import RxSwift
import ReactorKit
import RxFlow
import RxRelay

final class EmailVerificationViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    enum Action {
        case updateTextField(String)
        case sendVerificationEmail
        case dismiss
    }
    
    enum Mutation {
        case setEmail(String)
        case setErrorMessage(String)
        case setLoading(Bool)
        case dismiss
    }
    
    struct State {
        var email: String = ""
        var errorMessage: String?
        var isLoading: Bool = false
    }
    
    init(userService: UserServiceType) {
        self.userService = userService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateTextField(let text):
            return Observable.just(Mutation.setEmail(text))
            
        case .sendVerificationEmail:
            
            let emailValidationResult = currentState.email.isValidSchoolEmail
            if emailValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(emailValidationResult.rawValue))
            } else {
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    self.userService.sendVerificationEmail(email: currentState.email)
                        .asObservable()
                        .map { result in
                            switch result {
                            case .success:
                                self.steps.accept(AppStep.checkUserEmailGuideIsRequired(email: self.currentState.email))
                                return .dismiss
                            
                            case .error(let error):
                                let errorMessage = error == .E102
                                ? "인증에 사용된 적이 있는 이메일입니다.\n혹시 스팸 메일함도 확인해보셨나요?"
                                : error.errorDescription
                                return Mutation.setErrorMessage(errorMessage)
                            }
                        },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
        case .dismiss:
            return Observable.just(Mutation.dismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        state.errorMessage = nil
        
        switch mutation {
        case .setEmail(let email):
            state.email = email

        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
                        
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .dismiss: break
        }
        return state
    }
}
