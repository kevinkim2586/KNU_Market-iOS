//
//  NickNameInputViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/21.
//

import Foundation
import ReactorKit
import RxSwift
import RxRelay
import RxFlow

final class NickNameInputViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case checkDuplication
    }
    
    enum Mutation {
        case setUserNickname(String)
        case setErrorMessage(String)
        case empty
    }
    
    struct State {
        var userNickname: String = ""
        var errorMessage: String?
    }
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .updateTextField(text):
            return Observable.just(Mutation.setUserNickname(text))
            
        case .checkDuplication:
            
            let nicknameValidationResult = currentState.userNickname.isValidNickname
            if nicknameValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(nicknameValidationResult.rawValue))
            }
            
            return self.userService.checkDuplication(type: .nickname, infoString: currentState.userNickname)
                .asObservable()
                .map {  result in
                    switch result {
                    case .success(let duplicateCheckModel):
                        
                        if duplicateCheckModel.isDuplicate {
                            return Mutation.setErrorMessage(RegisterError.existingNickname.rawValue)
                        } else {
                            UserRegisterValues.shared.displayName = self.currentState.userNickname
                            self.steps.accept(AppStep.nicknameInputIsCompleted)
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
        switch mutation {
        case .setUserNickname(let userNickname):
            state.userNickname = userNickname
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        
        case .empty:
            break
        }
        return state
    }
    
}
