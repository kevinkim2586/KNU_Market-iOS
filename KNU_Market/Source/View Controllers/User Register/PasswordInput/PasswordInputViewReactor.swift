//
//  PasswordInputViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/20.
//

import UIKit
import ReactorKit
import RxFlow
import RxRelay

final class PasswordInputViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextFields([String])
        case pressedBottomButton
    }
    
    enum Mutation {
        case setUserPassword([String])
        case setErrorMessage(String)
        case empty
    }
    
    struct State {
        var userPassword: String = ""
        var userCheckPassword: String = ""
        var errorMessage: String = RegisterError.incorrectPasswordFormat.rawValue
        var errorMessageColor: UIColor = .lightGray
    }
    
    init(){
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .updateTextFields(texts):
            return Observable.just(Mutation.setUserPassword(texts))
            
        case .pressedBottomButton:
            let passwordValidationResult = currentState.userPassword.isValidPassword(alongWith: currentState.userCheckPassword)
                        
            if passwordValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(passwordValidationResult.rawValue))
            } else {
                UserRegisterValues.shared.password = currentState.userPassword
                self.steps.accept(AppStep.passwordInputIsCompleted)
                return Observable.just(Mutation.empty)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setUserPassword(texts):
            state.userPassword = texts[0]
            state.userCheckPassword = texts[1]
            state.errorMessageColor = UIColor.lightGray
            
        case let .setErrorMessage(errorMessage):
            state.errorMessage = errorMessage
            state.errorMessageColor = UIColor(named: K.Color.appColor) ?? .systemRed
            
        case .empty:
            break
        }
        return state
    }
}
