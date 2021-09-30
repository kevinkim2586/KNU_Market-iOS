import Foundation

//MARK: - Enum for managing different types of User Input Errors

enum ValidationError {
    
    //MARK: - Potential error when registering new user
    enum OnRegister: String, Error {
        
        case existingId                 = "생년월일 6자리를 입력해주세요. (981225)"
        case incorrectIdFormat          = "아이디에 특수 문자와 한글을 포함할 수 없어요."
        case incorrectIdLength          = "아이디는 4자 이상, 20자 이하로 적어주세요."
        case incorrectPasswordFormat    = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔"
        case passwordDoesNotMatch       = "비밀번호가 일치하지 않습니다.🤔"
        case existingNickname           = "이미 사용 중인 닉네임입니다.🥲"
        case incorrectNicknameFormat    = "유효하지 않은 닉네임이에요."
        case incorrectNicknameLength    = "닉네임은 2자 이상, 15자 이하로 적어주세요."
        case inValidEmailFormat         = "잘못된 이메일 주소 형식입니다."
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    
    
    //MARK: - Potential error when finding User Info
    enum OnFindingUserInfo: String, Error {
        
        case nonAuthorizedSchoolEmail   = "인증 이력이 없는 웹메일입니다."
        case incorrectSchoolEmailFormat = "이메일 형식이 올바르지 않습니다."
        case incorrectStudentIdFormat   = "학번 형식이 올바르지 않습니다."
        case incorrectBirthDateFormat   = "생년월일 6자리를 입력해주세요. (981225)"
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    //MARK: - Potential error when uploading new item/post
    
    enum OnUploadPost: String, Error {
        
        case titleTooShortOrLong        = "제목은 3글자 이상, 30자 이하로 작성해주세요.🤔"
        case detailTooShortOrLong       = "공구 내용을 3글자 이상, 700자 이하로 작성해주세요.🤔"
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    
    
}

