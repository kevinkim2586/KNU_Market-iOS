import Foundation

enum UserInputError: Error {
    
    case titleTooShortOrLong
    case detailTooShortOrLong
    
    var errorDescription: String {
        
        switch self {
        case .titleTooShortOrLong:
            return "제목은 3글자 이상, 30자 이하로 작성해주세요 🤔"
        case .detailTooShortOrLong:
            return "공구 내용을 3글자 이상, 250자 이하로 작성해주세요 🤔"
        }
    }
}
