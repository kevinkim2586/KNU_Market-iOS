import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    enum UpdateUserInfoType: String {
        case nickname   = "nickname"
        case password   = "password"
        case fcmToken   = "fcmToken"
        case image      = "image"
        case id         = "id"
        case email      = "email"
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
                self.updateUserFCMToken(with: UserRegisterValues.shared.fcmToken)
            } else { User.shared.fcmToken = infoString }
        case .image:
            User.shared.profileImageUID = infoString
        case .id:
            User.shared.userID = infoString
        case .email:
            User.shared.emailForPasswordLoss = infoString
        }
        
    }
    
    //MARK: - 프로필 이미지 수정 (DB상)
    func updateUserProfileImage(with uid: String,
                                completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [
            "nickname": User.shared.nickname,
            "password": User.shared.password,
            "image": uid,
            "fcmToken" : User.shared.fcmToken
        ]
        
        print("uid: \(uid)")
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 201:
                    print("UserManager - updateUserProfileImage success")
                    completion(.success(true))
                    User.shared.profileImageUID = uid
                    
                default:
                    print("UserManager - updateUserProfileImage failed default statement")
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 비밀번호 변경
    func updateUserPassword(with password: String,
                            completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [
            "nickname": User.shared.nickname,
            "password": password,
            "image": User.shared.profileImageUID,
            "fcmToken" : User.shared.fcmToken
        ]
        
        print("new password: \(password)")
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 201:
                    print("UserManager - updateUserPassword success")
                    completion(.success(true))
                    User.shared.password = password
                    
                default:
                    print("UserManager - updateUserPassword failed default statement")
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    
    
    //MARK: - 닉네임 변경
    func updateUserNickname(with nickname: String,
                            completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [
            "nickname": nickname,
            "password": User.shared.password,
            "image": User.shared.profileImageUID,
            "fcmToken" : User.shared.fcmToken
        ]
        
        print("new nickname: \(nickname)")
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 201:
                    print("UserManager - updateUserNickname success")
                    completion(.success(true))
                    User.shared.nickname = nickname
                    
                default:
                    print("UserManager - updateUserNickname failed default statement")
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    

    
    //MARK: - 사용자 FCM Token 업데이트
    func updateUserFCMToken(with token: String) {
        
        let parameters: Parameters = [
            "nickname": User.shared.nickname,
            "password": User.shared.password,
            "image": User.shared.profileImageUID,
            "fcmToken" : token
        ]
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                case 201:
                    print("✏️ UserManager - updateUserFCMToken SUCCESS with token: \(token)")
                    
                    if token != UserRegisterValues.shared.fcmToken {
                        
                        print("❗️ TOKEN DOES NOT MATCH, reupdating token")
                        self.updateUserFCMToken(with: UserRegisterValues.shared.fcmToken)
                        
                    } else {
                        User.shared.fcmToken = token
                    }
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ UserManager - updateUserFCMToken FAILED with error: \(error.errorDescription) and statusCode: \(statusCode)")
                }
            }
    }
}
