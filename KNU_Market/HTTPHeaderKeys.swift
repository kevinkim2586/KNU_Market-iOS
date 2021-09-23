import Foundation

enum HTTPHeaderKeys: String {
    
    case authentication = "authentication"
    case contentType = "Content-Type"
    case withoutcomplete = "withoutcomplete"
}

enum HTTPHeaderValues: String {
    
    case applicationJSON = "application/json"
    case multipartFormData = "multipart/form-data"
    case urlEncoded = "application/x-www-form-urlencoded"
}
