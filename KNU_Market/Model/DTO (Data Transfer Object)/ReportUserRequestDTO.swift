import Foundation
import Alamofire

struct ReportUserRequestDTO {
    
    var parameters: Parameters = [:]
    
    init(user: String, content: String) {
    
        parameters["title"] = user
        parameters["content"] = content
    }
}
