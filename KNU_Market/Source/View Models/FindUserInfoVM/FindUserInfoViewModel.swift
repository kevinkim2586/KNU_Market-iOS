import UIKit

protocol FindUserInfoViewModelDelegate: AnyObject {
    func didFindUserId(id: NSAttributedString)
    func didFindUserPassword(emailPasswordSent: NSAttributedString)
    
    func didFailFetchingData(errorMessage: String)
    func didFailValidatingUserInput(errorMessage: String)
}

extension FindUserInfoViewModelDelegate {
    func didFindUserId(id: NSAttributedString) {}
    func didFindUserPassword(emailPasswordSent: NSAttributedString) {}
}

class FindUserInfoViewModel {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    weak var delegate: FindUserInfoViewModelDelegate?
    
    typealias InputError = ValidationError.OnFindingUserInfo
    
    //MARK: - Initialization
    
    init(userManager: UserManager) {
        self.userManager = userManager
    }
    
    //MARK: - 아이디 찾기
    func findId(
        using option: FindUserInfoOption,
        mail: String? = nil,
        studentId: String? = nil,
        birthDate: String? = nil
    ) {
        showProgressBar()
        
        userManager?.findUserId(
            using: option,
            studentEmail: mail,
            studentId: studentId,
            studentBirthDate: birthDate
        ) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            
            switch result {
            case .success(let id):
                let attributedGuideString = self.filterSensitiveUserInfo(
                    infoString: id,
                    findUserInfoOption: option
                )
                self.delegate?.didFindUserId(id: attributedGuideString)
            case .failure(_):
                let errorMessage = option == .webMail ?
                InputError.nonAuthorizedSchoolEmail.rawValue : InputError.nonAuthorizedStudentId.rawValue
                self.delegate?.didFailFetchingData(errorMessage: errorMessage)
            }
        }
    }
    
    //MARK: - 비밀번호 찾기
    func findPassword(for userId: String) {
        showProgressBar()
        
        userManager?.findPassword(id: userId) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            
            switch result {
            case .success(let emailPasswordSent):
                let attributedGuideString = self.filterSensitiveUserInfo(
                    infoString: emailPasswordSent,
                    findUserInfoOption: .password
                )
                self.delegate?.didFindUserPassword(emailPasswordSent: attributedGuideString)
            case .failure(_):
                self.delegate?.didFailFetchingData(errorMessage: InputError.nonExistingUserId.rawValue)
            }
        }
        
    }
}

//MARK: - User Input Validation

extension FindUserInfoViewModel {
    
    func validateUserInput(
        findIdOption: FindUserInfoOption,
        mail: String? = nil,
        studentId: String? = nil,
        birthDate: String? = nil,
        userId: String? = nil
    ) {
        switch findIdOption {
        case .webMail:
            validateWebMail(mail: mail)
        case .studentId:
            validateStudentId(studentId: studentId, birthDate: birthDate)
        case .password:
            validateUserId(userId: userId)
        }
    }
    
    private func validateWebMail(mail: String?) {
        guard let mail = mail, mail.count != 0 else {
            delegate?.didFailValidatingUserInput(errorMessage: InputError.empty.rawValue)
            return
        }

        if !mail.contains("@knu.ac.kr") || !mail.isValidEmail {
            delegate?.didFailValidatingUserInput(errorMessage: InputError.incorrectSchoolEmailFormat.rawValue)
            return
        }
        findId(using: .webMail, mail: mail)
    }
    
    private func validateStudentId(studentId: String?, birthDate: String?) {
        guard
            let studentId = studentId,
            let birthDate = birthDate,
            studentId.count != 0,
            birthDate.count != 0 else {
                delegate?.didFailValidatingUserInput(errorMessage: InputError.empty.rawValue)
                return
            }
        if studentId.hasSpecialCharacters {
            delegate?.didFailValidatingUserInput(errorMessage: InputError.incorrectStudentIdFormat.rawValue)
            return
        }
        if birthDate.hasSpecialCharacters || birthDate.count != 6 {         // 생년월일 6자리
            delegate?.didFailValidatingUserInput(errorMessage: InputError.incorrectBirthDateFormat.rawValue)
            return
        }
        findId(using: .studentId, studentId: studentId, birthDate: birthDate)
    }
    
    private func validateUserId(userId: String?) {
        guard let userId = userId, userId.count != 0 else {
            delegate?.didFailValidatingUserInput(errorMessage: InputError.empty.rawValue)
            return
        }

        if !userId.isValidId, !userId.isValidEmail {
            delegate?.didFailValidatingUserInput(errorMessage: InputError.incorrectUserIdFormat.rawValue)
            return
        }
        findPassword(for: userId)
    }
}

//MARK: - String Filtering and Attribution Methods

extension FindUserInfoViewModel {
    
    private func filterSensitiveUserInfo(infoString: String, findUserInfoOption: FindUserInfoOption) -> NSAttributedString {
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
        
        let alertBodyText = findUserInfoOption == .password ?
        "\(filteredInfoString)\n위의 메일로 임시 비밀번호를 전송했습니다." :
        "회원님의 아이디는 \(filteredInfoString) 입니다."
        
        return makeCustomAttributedString(fullText: alertBodyText, textToCustomize: filteredInfoString)
    }
    
    private func makeCustomAttributedString(fullText: String, textToCustomize: String) -> NSAttributedString {
        let attributedMessage: NSAttributedString = fullText.attributedStringWithColor(
            [textToCustomize],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
        return attributedMessage
    }
    
}

