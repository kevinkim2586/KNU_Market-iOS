//
//  StudentIdVerificationViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/27.
//

import UIKit
import RxSwift
import ReactorKit

final class StudentIdVerificationViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias VerifyError = ValidationError.OnVerification
    
    enum Action {
        case updateStudentId(String)
        case updateStudentBirthDate(String)
        case updateStudentIdImage(UIImage?)
        case checkStudentIdDuplication
        case verifyStudentId
        case textFieldChanged
        case dismiss
    }
    
    enum Mutation {
        case setStudentId(String)
        case setStudentBirthDate(String)
        case setStudentIdImage(UIImage?)
        case setDidCheckDuplicate(Bool)
        case completeVerification(Bool)
        case setAlertMessage(String)
        case setLoading(Bool)
        case dismiss
    }
    
    struct State {
        var studentId: String = ""
        var studentBirthDate: String = ""
        var studentIdImageData: Data?
        var studentIdImage: UIImage = UIImage(named: K.Images.chatBubbleIcon)!
        var didCheckDuplicate: Bool = false
        var isVerified: Bool = false
        var alertMessage: String?
        var isLoading: Bool = false
    }
    
    init(userService: UserServiceType) {
        self.userService = userService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateStudentId(let studentId):
            return Observable.just(Mutation.setStudentId(studentId))
            
        case .updateStudentBirthDate(let birthDate):
            return Observable.just(Mutation.setStudentBirthDate(birthDate))
            
        case .updateStudentIdImage(let studentIdImage):
            return Observable.just(Mutation.setStudentIdImage(studentIdImage))
            
        case .checkStudentIdDuplication:
            
            guard currentState.studentId.count > 4 else {
                return Observable.just(Mutation.setAlertMessage(VerifyError.emptyStudentId.rawValue))
            }
            
            return self.userService.checkDuplication(type: .studentId, infoString: currentState.studentId)
                .asObservable()
                .map { result in
                    switch result {
                    case .success(let duplicateCheckModel):
                        return duplicateCheckModel.isDuplicate
                        ? Mutation.setAlertMessage(VerifyError.duplicateStudentId.rawValue)
                        : Mutation.setDidCheckDuplicate(true)
                    case .error(let error):
                        return Mutation.setAlertMessage(error.errorDescription)
                    }
                }
            
        case .verifyStudentId:
            
            let userInputValidationResult = self.validateUserInput()
            
            if userInputValidationResult != .correct {
                return Observable.just(Mutation.setAlertMessage(userInputValidationResult.rawValue))
            } else {
                
                let model = StudentIdVerificationDTO(
                    studentId: currentState.studentId,
                    studentBirth: currentState.studentBirthDate,
                    studentIdImageData: currentState.studentIdImageData!
                )
                
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    self.userService.uploadStudentIdVerificationInformation(model: model)
                        .asObservable()
                        .map { result in
                            switch result {
                            case .success:
                                return Mutation.completeVerification(true)
                            case .error(let error):
                                return Mutation.setAlertMessage(error.errorDescription)
                            }
                        },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
            
        case .textFieldChanged:
            return Observable.just(Mutation.setDidCheckDuplicate(false))
            
        case .dismiss:
            return Observable.just(Mutation.dismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil
        
        switch mutation {
        case .setStudentId(let studentId):
            state.studentId = studentId
            
        case .setStudentBirthDate(let birthDate):
            state.studentBirthDate = birthDate
            
        case .setStudentIdImage(let studentIdImage):
            state.studentIdImage = studentIdImage ?? UIImage(named: K.Images.chatBubbleIcon)!
            state.studentIdImageData = studentIdImage?.jpegData(compressionQuality: 0.9)
        
        case .setDidCheckDuplicate(let didCheckDuplicate):
            state.didCheckDuplicate = didCheckDuplicate
            state.alertMessage = didCheckDuplicate == true
            ? "사용하셔도 좋습니다 🎉"
            : nil
            
        case .completeVerification(let completeVerification):
            state.isVerified = completeVerification
            state.alertMessage = "인증 완료되었습니다😁"
            
        case .setAlertMessage(let errorMessage):
            state.alertMessage = errorMessage
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .dismiss: break
        }
        return state
    }
}

extension StudentIdVerificationViewReactor {
    
    func validateUserInput() -> ValidationError.OnVerification {
        
        guard currentState.didCheckDuplicate != false else {
            return .didNotCheckStudentIdDuplication
        }
        
        guard currentState.studentBirthDate.count == 6 else {
            return .incorrectBirthDateLength
        }
        
        guard currentState.studentIdImageData != nil else {
            return .didNotChooseStudentIdImage
        }
        
        return .correct
    }
}
