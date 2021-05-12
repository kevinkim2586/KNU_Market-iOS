import Foundation
import Alamofire

//MARK: - 다른 유저 프로필 조회 API

/*
 - URI : GET /api/v1/auth/:uid
 - Content-Type : application/json
 
 - Request Header:
 "authentication" : "string"
 
 - Response:
 -> 200 Ok
 "nickname" : "string",
 "profileImage" : "string"//이미지 코드 전송
 
 -> 412 Precondition Failed
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct LoadOtherUserProfileModel {
    
    let headers: HTTPHeaders = [
        .contentType("application/json"),
        .authorization("")
    ]
}
