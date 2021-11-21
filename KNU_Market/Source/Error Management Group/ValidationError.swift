import Foundation

//MARK: - Enum for managing different types of User Input Errors

enum ValidationError {
    
    //MARK: - when registering new user
    enum OnRegister: String, Error {
        
        case incorrectIdFormat          = "불가능한 아이디 형식입니다."
        case incorrectIdLength          = "아이디는 4자 이상, 30자 이하로 적어주세요."
        case existingId                 = "이미 사용 중인 아이디입니다.🥲"
        case incorrectPasswordFormat    = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요."
        case passwordDoesNotMatch       = "비밀번호가 일치하지 않습니다.🤔"
        case existingNickname           = "이미 사용 중인 닉네임입니다.🥲"
        case incorrectNicknameFormat    = "유효하지 않은 닉네임이에요."
        case incorrectNicknameLength    = "닉네임은 2자 이상, 15자 이하로 적어주세요."
        case invalidEmailFormat         = "잘못된 이메일 주소 형식입니다."
        case existingEmail              = "이미 존재하는 이메일입니다."
        case empty                      = "빈 칸이 없는지 확인해주세요.🧐"
    }
    
    //MARK: - when finding User Info
    enum OnFindingUserInfo: String, Error {
        
        case nonAuthorizedSchoolEmail   = "인증 이력이 없는 웹메일입니다."
        case incorrectSchoolEmailFormat = "이메일 형식이 올바르지 않습니다."
        case nonAuthorizedStudentId     = "인증 이력이 없습니다.\n학번과 생년월일을 다시 확인해주세요."
        case incorrectStudentIdFormat   = "학번 형식이 올바르지 않습니다."
        case incorrectBirthDateFormat   = "생년월일 6자리를 입력해주세요. (ex.981225)"
        case incorrectUserIdFormat      = "올바르지 않은 아이디 형식입니다."
        case nonExistingUserId          = "존재하지 않는 아이디입니다."
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    
    //MARK: - when verifying as a student
    enum OnVerification: String, Error {
        
        case didNotCheckStudentIdDuplication    = "학번 중복 확인을 먼저해주세요.🤔"
        case duplicateStudentId                 = "인증 내역이 존재하는 학번입니다."
        case emptyStudentId                     = "학번을 입력해주세요."
        case emptyBirthDate                     = "생년월일을 입력해주세요."
        case incorrectBirthDateLength           = "생년월일 6자리를 입력해주세요."
        case didNotChooseStudentIdImage         = "모바일 학생증 캡쳐본을 첨부해주세요."
        
    }
    
    //MARK: - when changing user info
    
    enum OnChangingUserInfo: String, Error {
        
        case incorrectIdFormat          = "불가능한 아이디 형식입니다."
        case incorrectIdLength          = "아이디는 4자 이상, 30자 이하로 적어주세요."
        case existingId                 = "이미 사용 중인 아이디입니다.🥲"
        case invalidEmailFormat         = "잘못된 이메일 주소 형식입니다."
        case existingEmail              = "이미 존재하는 이메일입니다."
        case incorrectNicknameLength    = "닉네임은 2자 이상, 15자 이하로 작성해주세요."
        case existingNickname           = "이미 사용 중인 닉네임입니다.🥲"
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    

    
    
    //MARK: - when uploading new item/post
    enum OnUploadPost: String, Error {
        
        case titleTooShortOrLong        = "제목은 3글자 이상, 30자 이하로 작성해주세요.🤔"
        case detailTooShortOrLong       = "공구 내용을 3글자 이상, 700자 이하로 작성해주세요.🤔"
        case empty                      = "빈 칸이 없는지 확인해주세요."
    }
    
    
}

