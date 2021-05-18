import Foundation

enum UserInputError: Error {
    
    case tooShort
    case tooLong
    
    var errorDescription: String {
        
        switch self {
        case .tooShort:
            return "너무 짧습니다. 다시 입력해주세요."
        case .tooLong:
            return "너무 깁니다. 다시 입력해주세요."
        }
    }
}
