//
//  PasswordInputViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/20.
//

import UIKit
import ReactorKit

final class PasswordInputViewReactor: Reactor {
    
    let initialState: State
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextFields([String])
        case pressedBottomButton
        case viewDidDisappear
    }
    
    enum Mutation {
        case setUserPassword([String])
        case setErrorMessage(String)
        case allowToGoNext(Bool)
    }
    
    struct State {
        var userPassword: String = ""
        var userCheckPassword: String = ""
        
        var isAllowedToGoNext: Bool = false
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
                return Observable.just(Mutation.allowToGoNext(true))
            }
            
        case .viewDidDisappear:
            return Observable.just(Mutation.allowToGoNext(false))
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
            state.isAllowedToGoNext = false
            
        case let .allowToGoNext(isAllowed):
            state.isAllowedToGoNext = isAllowed
            
        }
        return state
    }
}
