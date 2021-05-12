import Foundation
import Alamofire

//MARK: - 프로필 조회 API

/*
 - URI : GET /api/v1/auth
 - Content-Type : application/json
 
 - Request Header:
 "authentication" : "string"
 
 - Response:
 -> 200 Ok
 "id" : "string",
 "nickname" : "string",
 "profileImage" : "string"//이미지 코드 전송
 
 -> 412 Precondition Failed
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct LoadProfileModel {
    
    let headers: HTTPHeaders = [
        .contentType("application/json"),
        .authorization("")
    ]
    
}
