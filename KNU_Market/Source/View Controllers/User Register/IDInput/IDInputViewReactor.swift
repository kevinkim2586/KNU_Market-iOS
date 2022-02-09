//
//  IDInputReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/20.
//

import UIKit
import ReactorKit
import Moya
import RxRelay
import RxFlow

final class IDInputViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case checkDuplication
    }
    
    enum Mutation {
        case setUserId(String)
        case setErrorMessage(String)
        case empty
    }
    
    struct State {
        var userId: String = ""
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
                            self.steps.accept(AppStep.idInputIsCompleted)
                            return Mutation.empty
                        }
                        
                    case .error(let error):
                        return Mutation.setErrorMessage(error.errorDescription)
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {
            
        case .setUserId(let userId):
            state.userId = userId
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .empty:
            break
        }
        return state
    }
    
    
}
