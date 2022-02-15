import Foundation
import Alamofire

//MARK: - 회원가입용 Model

struct RegisterRequestDTO {
     
    let username: String            // username == 로그인할 때 사용하는 아이디
    let displayName: String
    let password: String
    let fcmToken: String
    let emailForPasswordLoss: String
    
    let headers: HTTPHeaders = [HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.multipartFormData.rawValue]
    
    init(username: String, password: String, displayName: String, fcmToken: String, emailForPasswordLoss: String) {
        self.username = username
        self.displayName = displayName
        self.password = password
        self.fcmToken = fcmToken
        self.emailForPasswordLoss = emailForPasswordLoss
    }
}
