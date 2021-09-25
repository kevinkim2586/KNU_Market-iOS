import Foundation
import Alamofire

struct ReportUserRequestDTO {
    
    var parameters: Parameters = [:]
    var postUID: String
    
    init(user: String, content: String, postUID: String) {
        parameters["userName"] = user
        parameters["content"] = content
        self.postUID = postUID
    }
}
