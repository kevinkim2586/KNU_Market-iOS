import Foundation
import Alamofire

//MARK: - 회원가입용 Model

struct RegisterRequestDTO {
     
    let id: String
    let password: String
    let nickname: String
    let fcmToken: String
    let emailForPasswordLoss: String
    
    
    let headers: HTTPHeaders = [HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.multipartFormData.rawValue]
    
    init(id: String, password: String, nickname: String, fcmToken: String, emailForPasswordLoss: String) {
        self.id = id
        self.password = password
        self.nickname = nickname
        self.fcmToken = fcmToken
        self.emailForPasswordLoss = emailForPasswordLoss
    }
}
