import Foundation

//MARK: - Enum for managing different types of User Input Errors

enum ValidationError: Error {
    
    //MARK: - Error that occurs when uploading a new post/item
    enum OnUploadPost: Error {
        case titleTooShortOrLong
        case detailTooShortOrLong
        
        var errorDescription: String {
            switch self {
            case .titleTooShortOrLong:
                return "제목은 3글자 이상, 30자 이하로 작성해주세요🤔"
            case .detailTooShortOrLong:
                return "공구 내용을 3글자 이상, 700자 이하로 작성해주세요 🤔"
            }
        }
    }
    
    
    

}

