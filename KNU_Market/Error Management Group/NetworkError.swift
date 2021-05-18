import Foundation

enum NetworkError: Error {
    
    case connectionError
    case serverError
    
    var errorDescription: String {
        
        switch self {
        case .connectionError:
            return "네트워크 연결 상태에 문제가 있습니다."
        case .serverError:
            return "서버 에러. 잠시 후 다시 시도해주세요."
        }
    }
}
