import Foundation
import Alamofire

//MARK: - 회원가입용 Model
/*
 - URI : POST /api/v1/auth
 - Content-Type: multipart/form-data
 
 - Request Body:
 "id" : "string",
 "password" : "string",
 "nickname" : "string",
 "image" : "string"
 
 - Response:
 -> 201 Created
 
 -> 403 Forbidden
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct RegisterModel {
    
    let id: String
    let password: String
    let nickname: String
    let image: Data?
    
    init(id: String, password: String, nickname: String, image: Data?) {
        
        self.id = id
        self.password = password
        self.nickname = nickname
        
        if let profileImage = image {
            self.image = profileImage
        } else { self.image = nil }
    }

    let headers: HTTPHeaders = [.contentType("multipart/form-data")]
    
}
