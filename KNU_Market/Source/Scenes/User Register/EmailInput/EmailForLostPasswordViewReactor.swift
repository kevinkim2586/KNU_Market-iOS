//
//  EmailForLostPasswordViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/21.
//

import UIKit
import ReactorKit
import RxRelay
import RxFlow

final class EmailForLostPasswordViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    typealias RegisterError = ValidationError.OnRegister
    
    enum Action {
        case updateTextField(String)
        case checkDuplication
    }
    
    enum Mutation {
        case setEmail(String)
        case setErrorMessage(String)
        case setLoading(Bool)
        case empty
    }
    
    struct State {
        var userEmail: String = ""
        var errorMessage: String?
        var isLoading: Bool = false
    }
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .updateTextField(text):
            return Observable.just(Mutation.setEmail(text))
            
        case .checkDuplication:
            let emailValidationResult = currentState.userEmail.isValidEmailFormat
            if emailValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(emailValidationResult.rawValue))
            }
            
            #warning("추후 수정")
            
            UserRegisterValues.shared.emailForPasswordLoss = self.currentState.userEmail

            let model = RegisterRequestDTO(
                username: UserRegisterValues.shared.username,
                password: UserRegisterValues.shared.password,
                displayName: UserRegisterValues.shared.displayName,
                fcmToken: UserRegisterValues.shared.fcmToken,
                emailForPasswordLoss: UserRegisterValues.shared.emailForPasswordLoss
            )

            print("✅ model: \(model)")
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.userService.register(with: model)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success:
                            self.steps.accept(AppStep.emailInputIsCompleted)
                            return Mutation.empty
                        case .error(let error):
                            return Mutation.setErrorMessage(error.errorDescription)
                        }
                    },
                Observable.just(Mutation.setLoading(false))
            ])
            
            
//            return self.userService.checkDuplication(type: .email, infoString: currentState.userEmail)
//                .asObservable()
//                .flatMap { result -> Observable<Mutation> in
//
//                    switch result {
//                    case .success(let duplicateCheckModel):
//
//                        if duplicateCheckModel.isDuplicate {
//                            return Observable.just(Mutation.setErrorMessage(RegisterError.existingEmail.rawValue))
//                        }
//                        else {
//                            UserRegisterValues.shared.emailForPasswordLoss = self.currentState.userEmail
//
//                            let model = RegisterRequestDTO(
//                                username: UserRegisterValues.shared.username,
//                                password: UserRegisterValues.shared.password,
//                                displayName: UserRegisterValues.shared.displayName,
//                                fcmToken: UserRegisterValues.shared.fcmToken,
//                                emailForPasswordLoss: UserRegisterValues.shared.emailForPasswordLoss
//                            )
//
//                            return Observable.concat([
//                                Observable.just(Mutation.setLoading(true)),
//                                self.userService.register(with: model)
//                                    .asObservable()
//                                    .map { result in
//                                        switch result {
//                                        case .success:
//                                            self.steps.accept(AppStep.emailInputIsCompleted)
//                                            return Mutation.empty
//                                        case .error(let error):
//                                            return Mutation.setErrorMessage(error.errorDescription)
//                                        }
//                                    },
//                                Observable.just(Mutation.setLoading(false))
//                            ])
//                        }
//
//                    case .error(let error):
//                        return Observable.just(Mutation.setErrorMessage(error.errorDescription))
//                    }
//                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
            
        case let .setEmail(email):
            state.userEmail = email
            
        case let .setErrorMessage(errorMessage):
            state.errorMessage = errorMessage
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            
        default: break
        }
        return state
    }
}
