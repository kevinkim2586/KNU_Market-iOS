import Foundation
import Alamofire

struct ReportUserModel {
    
    let user: String
    let content: String
    
    var parameters: Parameters = [:]
    
    init(user: String, content: String) {
        
        self.user = user
        self.content = content
    
        parameters["title"] = self.user
        parameters["content"] = self.content
    }
}
