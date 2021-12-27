//
//  ChangeUserInfoReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/27.
//

import UIKit
import RxSwift
import ReactorKit

final class ChangeUserInfoReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias InputError = ValidationError.OnRegister
    
    enum Action {
        case updateIdTextField(String)
        case updateNicknameTextField(String)
        case updatePasswordTextFields([String])
        case updateEmailTextField(String)
        case updateUserInfo(UpdateUserInfoType, CheckDuplicationType)
    }
    
    enum Mutation {
        case setId(String)
        case setNickname(String)
        case setPasswords([String])
        case setEmail(String)
        
        case setAlertMessage(String)
        case setErrorMessage(String)
        case setLoading(Bool)
        case setCompletionStatus(Bool)
    }
    
    struct State {
        var userId: String = ""
        var userNickname: String = ""
        var userPassword: String = ""
        var userCheckPassword: String = ""
        var userEmailForPasswordLoss: String = ""
        
        var isLoading: Bool = false
        var alertMessage: String?
        var errorMessage: String?
        var changeComplete: Bool = false
    }
    
    init(userService: UserServiceType) {
        self.userService = userService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateIdTextField(let text):
            return Observable.just(Mutation.setId(text))
            
        case .updateNicknameTextField(let text):
            return Observable.just(Mutation.setNickname(text))
            
        case .updatePasswordTextFields(let texts):
            return Observable.just(Mutation.setPasswords(texts))
            
        case .updateEmailTextField(let text):
            return Observable.just(Mutation.setEmail(text))
            
        case .updateUserInfo(let updateUserInfoType, let checkDuplicationType):
            
            let userInputValidation: InputError
            let updatedInfoString: String
            
            switch updateUserInfoType {
            case .id:
                userInputValidation = currentState.userId.isValidID
                updatedInfoString = currentState.userId
                
            case .nickname:
                userInputValidation = currentState.userNickname.isValidNickname
                updatedInfoString = currentState.userNickname
                
            case .password:
                userInputValidation = currentState.userPassword.isValidPassword(alongWith: currentState.userCheckPassword)
                updatedInfoString = currentState.userPassword
                
            case .email:
                userInputValidation = currentState.userEmailForPasswordLoss.isValidEmailFormat
                updatedInfoString = currentState.userEmailForPasswordLoss
                
            default:
                return Observable.just(Mutation.setErrorMessage(NetworkError.E000.rawValue))
            }
            
            if userInputValidation != .correct {
                return Observable.just(Mutation.setErrorMessage(userInputValidation.rawValue))
            } else {
                
                // 먼저 중복인지 체크한 다음에 유저 정보 업데이트 수행
                
                return self.userService.checkDuplication(type: checkDuplicationType, infoString: updatedInfoString)
                    .asObservable()
                    .flatMap { result -> Observable<Mutation> in
                        switch result {
                        case .success(let duplicateCheckModel):
                            if duplicateCheckModel.isDuplicate {
                                return Observable.just(Mutation.setErrorMessage(self.getDuplicateErrorMessage(updateUserInfoType: updateUserInfoType)))
                            } else {
                                return Observable.concat([
                                    Observable.just(Mutation.setLoading(true)),
                                    self.userService.updateUserInfo(type: updateUserInfoType, updatedInfo: updatedInfoString)
                                        .asObservable()
                                        .map { result in
                                            switch result {
                                            case .success:
                                                return Mutation.setCompletionStatus(true)
                                            case .error(let error):
                                                return Mutation.setErrorMessage(error.errorDescription)
                                            }
                                        },
                                    Observable.just(Mutation.setLoading(false))
                                ])
                            }
                        case .error(let error):
                            return Observable.just(Mutation.setErrorMessage(error.errorDescription))
                        }
                    }
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil
        state.errorMessage = nil
        
        switch mutation {
        case .setId(let id):
            state.userId = id
            
        case .setNickname(let nickname):
            state.userNickname = nickname
            
        case .setPasswords(let passwords):
            state.userPassword = passwords[0]
            state.userCheckPassword = passwords[1]
            
        case .setEmail(let email):
            state.userEmailForPasswordLoss = email
            
        case .setAlertMessage(let alertMessage):
            state.alertMessage = alertMessage
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setCompletionStatus(let completed):
            state.changeComplete = completed
        }
        return state
    }
}

extension ChangeUserInfoReactor {
    
    private func getDuplicateErrorMessage(updateUserInfoType: UpdateUserInfoType) -> String {
        let errorMessage: String
        switch updateUserInfoType {
        case .nickname:
            errorMessage = InputError.existingNickname.rawValue
        case .id:
            errorMessage = InputError.existingId.rawValue
        case .email:
            errorMessage = InputError.existingEmail.rawValue
        default: errorMessage = ""
        }
        return errorMessage
    }
}
