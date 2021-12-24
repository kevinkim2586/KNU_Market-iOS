//
//  IDInputReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/20.
//

import UIKit
import ReactorKit
import Moya

final class IDInputViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case checkDuplication
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
        var errorMessage: String?
    }

    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateTextField(let text):
            return Observable.just(Mutation.setUserId(text))
            
        case .checkDuplication:
            
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
