//
//  FindUserInfoViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/22.
//

import UIKit
import RxSwift
import ReactorKit

final class FindUserInfoViewReactor: Reactor {
    
    let initialState: State
    let userService: UserServiceType
    
    typealias InputError = ValidationError.OnFindingUserInfo
    
    enum Action {

        case updateSchoolEmail(String)
        case updateStudentIdAndStudentBirthDate([String])
        case updateId(String)
        
        case findIdUsingStudentId
        case findIdUsingSchoolEmail
        case findPassword
    }
  
    enum Mutation {
        case setStudentIdAndBirthDate([String])
        case setSchoolEmail(String)
        case setId(String)
        
        case setFoundId(NSAttributedString)
        case setEmailNewPasswordSent(NSAttributedString)
        
        case setLoading(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
            
        var studentId: String = ""              // 학번 - 학생증 인증으로 아이디 찾을 시 사용
        var studentBirthDate: String = ""       // 생년월일 - 학생증 인증으로 아이디 찾을 시 사용
        var schoolEmail: String = ""            // KNU 웹메일 - 웹메일 인증으로 아이디 찾을 시 사용
        var id: String = ""                     // 비밀번호 찾기 때 사용할 크누마켓 로그인 아이디
        
        
        var foundId: NSAttributedString?
        var emailNewPasswordSent: NSAttributedString?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    init(userService: UserServiceType) {
        self.initialState = State()
        self.userService = userService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateStudentIdAndStudentBirthDate(let texts):
            return Observable.just(Mutation.setStudentIdAndBirthDate(texts))
            
        case .updateSchoolEmail(let text):
            return Observable.just(Mutation.setSchoolEmail(text))
            
        case .updateId(let text):
            return Observable.just(Mutation.setId(text))
            
        case .findIdUsingStudentId:
                    
            let studentIdValidationResult = currentState.studentId.isValidStudentIdFormat(alongWith: currentState.studentBirthDate)
            
            if studentIdValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(studentIdValidationResult.rawValue))
            } else {
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    self.userService.findUserId(
                        option: .studentId,
                        studentEmail: nil,
                        studentId: currentState.studentId,
                        studentBirthDate: currentState.studentBirthDate
                    )
                        .asObservable()
                        .map { result in
                            switch result {
                            case .success(let findIdModel):
                                
                                let attributedIdGuideString = self.filterSensitiveUserInfo(
                                    infoString: findIdModel.id,
                                    findUserInfoOption: .studentId
                                )
                                return Mutation.setFoundId(attributedIdGuideString)
                                
                            case .error(_):
                                let errorMessage = InputError.nonAuthorizedStudentId.rawValue
                                return Mutation.setErrorMessage(errorMessage)
                            }
                        },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
            
        case .findIdUsingSchoolEmail:
            
            let schoolEmailValidationResult = currentState.schoolEmail.isValidSchoolEmail
            
            if schoolEmailValidationResult != .correct {
                return Observable.just(Mutation.setErrorMessage(schoolEmailValidationResult.rawValue))
            } else {
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    self.userService.findUserId(
                        option: .schoolEmail,
                        studentEmail: currentState.schoolEmail,
                        studentId: nil,
                        studentBirthDate: nil
                    )
                        .asObservable()
                        .map { result in
                            switch result {
                            case .success(let findIdModel):
                                
                                let attributedIdGuideString = self.filterSensitiveUserInfo(
                                    infoString: findIdModel.id,
                                    findUserInfoOption: .studentId
                                )
                                return Mutation.setFoundId(attributedIdGuideString)
                                
                            case .error(_):
                                let errorMessage = InputError.nonAuthorizedSchoolEmail.rawValue
                                return Mutation.setErrorMessage(errorMessage)
                            }
                        },
                    
                    Observable.just(Mutation.setLoading(false))
                ])
            }
            
        case .findPassword:                 // 비번 찾을 때에는 별도 Input Validation 이 없음
            
            guard !currentState.id.isEmpty else {
                return Observable.just(Mutation.setErrorMessage(InputError.empty.rawValue))
            }
            
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.userService.findPassword(id: currentState.id)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let findPasswordModel):
                            
                            let attributedGuideString = self.filterSensitiveUserInfo(
                                infoString: findPasswordModel.email,
                                findUserInfoOption: .password
                            )
                            return Mutation.setEmailNewPasswordSent(attributedGuideString)
                            
                        case .error(_):
                            let errorMessage = InputError.nonExistingUserId.rawValue
                            return Mutation.setErrorMessage(errorMessage)
                        }
                    },
            
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setStudentIdAndBirthDate(let texts):
            state.studentId = texts[0]
            state.studentBirthDate = texts[1]
            state.foundId = nil
            state.errorMessage = nil

        case .setSchoolEmail(let schoolEmail):
            state.schoolEmail = schoolEmail
            state.foundId = nil
            state.errorMessage = nil

        case .setId(let id):
            state.id = id
            state.emailNewPasswordSent = nil
            state.errorMessage = nil
            
        case .setFoundId(let foundId):
            state.foundId = foundId
            
        case .setEmailNewPasswordSent(let email):
            state.emailNewPasswordSent = email
            state.errorMessage = nil
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
}

//MARK: - Filtering & Customization Methods

extension FindUserInfoViewReactor {
    
    /// 사용자 아이디를 알려줄 때 최소한의 민감한 정보를 가리기 위한 함수
    private func filterSensitiveUserInfo(
        infoString: String,
        findUserInfoOption: FindUserInfoOption
    ) -> NSAttributedString {
        var filteredInfoString: String
        
        // 이메일 형식의 아이디라면 @ 앞에 부분을 *로 처리 -> 아이디가 @knu.ac.kr 일 수도 있고, @gmail.com 이 될 수도 있음
        if infoString.isValidEmail {
            filteredInfoString = infoString.replacingOccurrences(
                of: #"[A-Z0-9a-z]@"#,
                with: "*@",
                options: .regularExpression,
                range: nil
            )
        }
        // 그냥 String 형태의 아이디라면 마지막 Character 만 *로 처리
        else {
            var userInfoString = infoString
            userInfoString.remove(at: userInfoString.index(before: userInfoString.endIndex))
            userInfoString.append("*")
            filteredInfoString = userInfoString
        }
        
        let alertBodyText = findUserInfoOption == .password
        ? "\(filteredInfoString)\n위의 메일로 임시 비밀번호를 전송했습니다."
        : "회원님의 아이디는 \(filteredInfoString) 입니다."
        
        return makeCustomAttributedString(fullText: alertBodyText, textToCustomize: filteredInfoString)
    }
    
    private func makeCustomAttributedString(
        fullText: String,
        textToCustomize: String
    ) -> NSAttributedString {
        let attributedMessage: NSAttributedString = fullText.attributedStringWithColor(
            [textToCustomize],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
        return attributedMessage
    }
    
}
