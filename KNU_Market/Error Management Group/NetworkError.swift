import Foundation

//enum NetworkError: Error {
//
//    case connectionError
//    case serverError
//
//
//    var errorDescription: String {
//
//        switch self {
//        case .connectionError:
//            return "네트워크 연결 상태에 문제가 있습니다."
//        case .serverError:
//            return "서버 에러. 잠시 후 다시 시도해주세요."
//        }
//    }
//}

enum NetworkError: Error {
    
    // invalid account error
    case E101
    case E102
    case E103
    case E104
    case E105
    case E106
    case E107
    case E108
    case E109
    
    // invalid request
    case E201
    
    // invalid grant
    case E301
    case E302
    case E303
    
    // invalid form
    case E401
    case E402
    
    // invalid file
    case E501
    
    // invalid post
    case E601
    
    var errorDescription: String {
        
        switch self {
        
        case .E101:
            return "id 또는 password가 일치하지 않습니다."
        case .E102:
            return "이미 존재하는 계정입니다."
        case .E103:
            return "잘못된 아이디 형식"
        case .E104:
            return "잘못된 비밀번호 형식"
        case .E105:
            return "잘못된 이메일 형식"
        case .E106:
            return "인증 코드가 일치하지 않음"
        case .E107:
            return "이메일 인증 필요"
        case .E108:
            return "존재하지 않는 계정"
        case .E109:
            return "권한 없음"
   
        case .E201:
            return "refresh_token 누락"
            
        case .E301:
            return "잘못되거나 만료된 refresh_token"
        case .E302:
            return "잘못되거나 만료된 access_token"
        case .E303:
            return "중복 데이터 존재"
            
        case .E401:
            return "잘못된 형식의 요청"
        case .E402:
            return "잘못되거나 만료된 요청"
            
        case .E501:
            return "존재하지 않는 파일"
            
        case .E601:
            return "존재하지 않는 글"
        }
    }
}
