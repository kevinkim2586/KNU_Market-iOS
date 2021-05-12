import Foundation
import Alamofire

//MARK: - 중복체크 API
/*
 - URI : GET /api/v1/duplicate
 - Content-Type : application/json
 
 - Request Header:
 -> "id" : "string"
 
 - Response:
 -> 200 Ok
 
 -> 403 Forbidden
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct CheckDuplicateModel {
    
    let id: String
    
    init(id: String) {
        
        self.id = id
        headers["id"] = self.id
    }
    
    var headers: HTTPHeaders = [
        .contentType("application/json")
    ]
}
