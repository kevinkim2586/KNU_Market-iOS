import Foundation
import Alamofire

//MARK: - 프로필 수정 API
/*
 - URI : PATCH /api/v1/auth 
 - Content-Type: multipart/form-data
 
 - Request Header:
 -> "application/json" : "string"
 
 - Request form-data
 "nickname" : "string",
 "password" : "string",
 "image" : "string"//이미지 코드 삽입
 
 - Response:
 -> 201 Created
 
 -> 403 Forbidden
 -> 412 Precondition Failed
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct ChangeProfileModel {
    
    let nickname: String
    let password: String
    let image: String
    
    init(nickname: String, password: String, image: String) {
        
        self.nickname = nickname
        self.password = password
        self.image = image
    }
    
    let headers: HTTPHeaders = [
        HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.multipartFormData.rawValue,
    ]
}
