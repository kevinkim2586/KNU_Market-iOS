//
//  IDInputReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/20.
//

import UIKit
import ReactorKit
import Moya

final class IDInputReactor: Reactor {
    
    let initialState: State
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case pressedBottomButton
        case viewDidDisappear
    }
    
    enum Mutation {
        case setUserId(String)
        case setErrorMessage(String)
        case allowToGoNext(Bool)
    }
    
    struct State {
        var userId: String = ""
        var isAllowedToGoNext: Bool = false
        var idValidation: ValidationError.OnRegister?
        var errorMessage: String?
    }
    
    let userService: UserServiceType
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateTextField(let text):
            return Observable.just(Mutation.setUserId(text))
            
        case .pressedBottomButton:
            
            let idValidationResult = currentState.userId.isValidID
            if idValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(idValidationResult.rawValue))
            }
            
            return self.userService.checkDuplication(type: .id, infoString: currentState.userId)
                .asObservable()
                .map { result in
                    switch result {
                    case .success(let duplicateCheckModel):
                        
                        if duplicateCheckModel.isDuplicate {
                            return Mutation.setErrorMessage(RegisterError.existingId.rawValue)
                        } else {
                            UserRegisterValues.shared.userId = self.currentState.userId
                            return Mutation.allowToGoNext(true)
                        }
                    
                    case .error(let error):
                        return Mutation.setErrorMessage(error.errorDescription)
                    }
                }
        case .viewDidDisappear:
            return Observable.just(Mutation.allowToGoNext(false))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
            
        case .setUserId(let userId):
            state.userId = userId

        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            state.isAllowedToGoNext = false
            
        case .allowToGoNext(let isAllowed):
            state.isAllowedToGoNext = isAllowed

            
        }
        return state
    }
    
    
}
