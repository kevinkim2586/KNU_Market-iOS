import Foundation

//MARK: - Enum for managing different types of User Input Errors

enum ValidationError {
    
    //MARK: - Potential error when registering new user
    
    enum OnRegister: Error {
        
        case existingId
        case incorrectIdFormat
        case incorrectIdLength
        case incorrectPasswordFormat
        case passwordDoesNotMatch
        case existingNickname
        case incorrectNicknameFormat
        case incorrectNicknameLength
        case inValidEmailFormat
        
        var errorDescription: String {
            switch self {
            case .existingId:
                return "이미 사용 중인 아이디입니다.🥲"
            case .incorrectIdFormat:
                return "아이디에 특수 문자와 한글을 포함할 수 없어요."
            case .incorrectIdLength:
                return "아이디는 4자 이상, 20자 이하로 적어주세요."
            case .incorrectPasswordFormat:
                return "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔"
            case .passwordDoesNotMatch:
                return "비밀번호가 일치하지 않습니다.🤔"
            case .existingNickname:
                return "이미 사용 중인 닉네임입니다.🥲"
            case .incorrectNicknameFormat:
                return "유효하지 않은 닉네임이에요."
            case .incorrectNicknameLength:
                return "닉네임은 2자 이상, 15자 이하로 적어주세요."
            case .inValidEmailFormat:
                return "잘못된 이메일 주소 형식입니다."
            }
        }
    }
    
    
    //MARK: - Potential error when finding User Info
    
    enum OnFindingUserInfo: Error {
        
        case nonAuthorizedSchoolEmail
        case incorrectBirthDateFormat
        
        var errorDescription: String {
            switch self {
            case .nonAuthorizedSchoolEmail:
                return "인증 이력이 없는 웹메일입니다."
            case .incorrectBirthDateFormat:
                return "생년월일 6자리를 입력해주세요. (981225)"
            }
        }
    }
    
    //MARK: - Potential error when uploading new item/post
    
    enum OnUploadPost: Error {
        
        case titleTooShortOrLong
        case detailTooShortOrLong
        
        var errorDescription: String {
            switch self {
            case .titleTooShortOrLong:
                return "제목은 3글자 이상, 30자 이하로 작성해주세요.🤔"
            case .detailTooShortOrLong:
                return "공구 내용을 3글자 이상, 700자 이하로 작성해주세요.🤔"
            }
        }
    }
    
    
    

}

