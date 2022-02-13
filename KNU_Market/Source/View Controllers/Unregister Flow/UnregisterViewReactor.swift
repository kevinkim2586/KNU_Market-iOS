//
//  UnregisterViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/27.
//

import UIKit
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

final class UnregisterViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let userService: UserServiceType
    
    enum Action {
        case updatePasswordInput(String)
        case tryLoggingIn
        case updateFeedBackContext(String)
        case sendFeedBack
        case openKakaoHelpChannelLink
    }
    
    enum Mutation {
        case setPassword(String)
        case setFeedBackContext(String)
        case setLoading(Bool)
        case setErrorMessage(String)
        case setAlertMessage(String)
        case empty
    }
    
    struct State {
        var userId: String = User.shared.userID
        var password: String = ""
        var userFeedback: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        var alertMessage: String?
    }
    
    init(userService: UserServiceType) {
        self.userService = userService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updatePasswordInput(let password):
            return Observable.just(Mutation.setPassword(password))
            
        case .tryLoggingIn:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                login(),
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .updateFeedBackContext(let feedback):
            return Observable.just(Mutation.setFeedBackContext(feedback))
            
        case .sendFeedBack:
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                sendFeedback(),
                unregister(),
                Observable.just(Mutation.setLoading(false))
            ])

        case .openKakaoHelpChannelLink:
            self.steps.accept(AppStep.kakaoHelpChannelLinkIsRequired)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        switch mutation {
        case .setPassword(let password):
            state.password = password
            
        case .setFeedBackContext(let feedback):
            state.userFeedback = feedback
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setAlertMessage(let alertMessage):
            state.alertMessage = alertMessage

        default: break
        }
        return state
    }
}


//MARK: - API Methods

extension UnregisterViewReactor {
    
    private func login() -> Observable<Mutation> {
        
        return self.userService.login(id: currentState.userId, password: currentState.password)
            .asObservable()
            .map { result in
                switch result {
                case .success(_):
                    self.steps.accept(AppStep.inputSuggestionForUnregisterIsRequired)
                    return .empty
                
                case .error(let error):
                    let errorMessage = error == .E101
                    ? "비밀번호가 일치하지 않습니다. 다시 시도해 주세요."
                    : error.errorDescription
                    return Mutation.setErrorMessage(errorMessage)
                }
            }
    }
    
    private func sendFeedback() -> Observable<Mutation> {
        
        let feedback = "회원 탈퇴 사유: \(currentState.userFeedback)"
        
        return self.userService.sendFeedback(content: feedback)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    return Mutation.empty
                case .error(_):
                    return Mutation.setErrorMessage("피드백 보내기에 실패하였습니다. 잠시 후 다시 시도해주세요.")
                }
            }
    }
    
    private func unregister() -> Observable<Mutation> {
        
        return self.userService.unregisterUser()
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    self.steps.accept(AppStep.unregisterIsCompleted)
                    return Mutation.empty
            
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription)
                }
            }
    }
}
