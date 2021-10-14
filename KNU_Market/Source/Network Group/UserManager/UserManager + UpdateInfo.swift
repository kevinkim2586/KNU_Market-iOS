import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    enum UpdateUserInfoType: String {
        case nickname       = "nickname"
        case password       = "password"
        case fcmToken       = "fcmToken"
        case profileImage   = "image"
        case id             = "id"
        case email          = "email"
    }
    
    func updateUserInfo(
        type: UpdateUserInfoType,
        infoString: String,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        let parameters: Parameters = [type.rawValue: infoString]
        
        AF.request(
            userProfileUpdateURL,
            method: .put,
            parameters: parameters,
            encoding: JSONEncoding.default,
            interceptor: interceptor
        )
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.E000))
                    return
                }
                switch statusCode {
                case 201:
                    print("✏️ UserManager - updateUserInfo SUCCESS")
                    self.updateLocalUserInfo(type: type, infoString: infoString)
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ UserManager - updateUserInfo FAILED with statusCode: \(statusCode) and reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    func updateLocalUserInfo(type: UpdateUserInfoType, infoString: String) {
        
        switch type {
        case .nickname:
            User.shared.nickname = infoString
        case .password:
            User.shared.password = infoString
        case .fcmToken:
            if infoString != UserRegisterValues.shared.fcmToken {
                print("❗️ TOKEN DOES NOT MATCH, Re-updating token")
                self.updateUserInfo(type: .fcmToken, infoString: UserRegisterValues.shared.fcmToken) { _ in }
            } else { User.shared.fcmToken = infoString }
        case .profileImage:
            User.shared.profileImageUID = infoString
        case .id:
            User.shared.userID = infoString
        case .email:
            User.shared.emailForPasswordLoss = infoString
        }
        
    }
}
