//
//  NickNameInputViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/21.
//

import Foundation
import ReactorKit
import RxSwift

final class NickNameInputViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case checkDuplication
        case viewDidDisappear
    }
    
    enum Mutation {
        case setUserNickname(String)
        case setErrorMessage(String)
        case allowToGoNext(Bool)
    }
    
    struct State {
        var userNickname: String = ""
        var isAllowedToGoNext: Bool = false
        var nicknameValidation: ValidationError.OnRegister?
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
                            UserRegisterValues.shared.nickname = self.currentState.userNickname
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
        case .setUserNickname(let userNickname):
            state.userNickname = userNickname
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            state.isAllowedToGoNext = false
            
        case .allowToGoNext(let isAllowed):
            state.isAllowedToGoNext = isAllowed
            state.errorMessage = nil
        }
        return state
    }
    
}
