import Foundation

protocol FindUserInfoViewModelDelegate: AnyObject {
    func didFindUserId(id: String)
    func didFindUserPassword()
    
    func didFailFetchingData(with error: NetworkError)
    func didFailValidatingUserInput(errorMessage: String)
}

extension FindUserInfoViewModelDelegate {
    func didFindUserId(id: String) {}
    func didFindUserPassword() {}
}

class FindUserInfoViewModel {
    
    weak var delegate: FindUserInfoViewModelDelegate?
    
    
    func findId(
        using option: FindIdOption,
        mail: String? = nil,
        studentId: String? = nil,
        birthDate: String? = nil
    ) {
        UserManager.shared.findUserId(
            using: option,
            studentEmail: mail,
            studentId: studentId,
            studentBirthDate: birthDate
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let id):
                self.delegate?.didFindUserId(id: self.filterSensitiveUserInfo(infoString: id))
            case .failure(let error):
                self.delegate?.didFailFetchingData(with: error)
            }
        }
    }
}

//MARK: - User Input Validation

extension FindUserInfoViewModel {
    
    typealias InputError = ValidationError.OnFindingUserInfo
    
    func validateUserInput(
        findIdOption: FindIdOption,
        mail: String? = nil,
        studentId: String? = nil,
        birthDate: String? = nil
    ) {
        switch findIdOption {
        case .webMail:
            validateWebMail(mail: mail)
        case .studentId:
            validateStudentId(studentId: studentId, birthDate: birthDate)
        }
    }
    
    private func validateWebMail(mail: String?) {
        guard let mail = mail else {
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
        guard let studentId = studentId, let birthDate = birthDate else {
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
}

//MARK: - Section Heading

extension FindUserInfoViewModel {
    
    private func filterSensitiveUserInfo(infoString: String) -> String {
        
        var filteredInfoString: String
        
        // 이메일 형식의 아이디라면 @ 앞에 부분을 *로 처리
        if infoString.contains("@knu.ac.kr") {
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
        return filteredInfoString
    }
}
