import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class UserManager {
    
    //MARK: - Singleton
    static let shared: UserManager = UserManager()
    
    private init() {}
    
    //MARK: - API Request URLs
    let registerURL                 = "\(Constants.API_BASE_URL)auth"
    let loginURL                    = "\(Constants.API_BASE_URL)login"
    let checkNicknameDuplicateURL   = "\(Constants.API_BASE_URL)duplicate/nickname"
    let logoutURL                   = "\(Constants.API_BASE_URL)logout"
    let requestAccessTokenURL       = "\(Constants.API_BASE_URL)token"
    let findPasswordURL             = "\(Constants.API_BASE_URL)findpassword"
    let loadUserProfileURL          = "\(Constants.API_BASE_URL)auth"
    let userProfileUpdateURL        = "\(Constants.API_BASE_URL)auth"
    let unregisterURL               = "\(Constants.API_BASE_URL)auth"
    
    let interceptor = Interceptor()
    
    
    //MARK: - 회원가입
    func register(with model: RegisterRequestDTO,
                  completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.upload(multipartFormData: { multipartFormData in
            
            
            multipartFormData.append(Data(model.id.utf8),
                                     withName: "id")
            multipartFormData.append(Data(model.password.utf8),
                                     withName: "password")
            multipartFormData.append(Data(model.nickname.utf8),
                                     withName: "nickname")
            
            if let profileImageData = model.imageData {
                multipartFormData.append(profileImageData,
                                         withName: "media",
                                         fileName: "userProfileImage.jpeg",
                                         mimeType: "image/jpeg")
            }
            
        }, to: registerURL,
        headers: model.headers).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 201:
                print("✏️ UserManager - register SUCCESS")
                completion(.success(true))
            default:
                let error = NetworkError.returnError(json: response.data!)
                print("❗️ UserManager - register FAILED")
                completion(.failure(error))
            }
        }
    }
    
    
    //MARK: - 닉네임 중복 체크
    func checkNicknameDuplicate(nickname: String,
                                completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
        
        let parameters: Parameters = ["name": nickname]
        let headers: HTTPHeaders = [ HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.urlEncoded.rawValue]
        
        AF.request(checkNicknameDuplicateURL,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.queryString,
                   headers: headers,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                case 200:
                    do {
                        
                        let json = try JSON(data: response.data!)
                        let result = json["isDuplicate"].boolValue
                        
                        print("✏️ USER MANAGER - duplicateNickname Result: \(result)")
                        
                        result == false ? completion(.success(true)) : completion(.success(false))
                        
//                        result == "false" ? completion(.success(true)) : completion(.success(false))
                        
                    } catch {
                        print("UserManager - checkDuplicate() catch error: \(error)")
                        completion(.failure(.E000))
                    }
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 로그인
    func login(email: String,
               password: String,
               completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
        
        let parameters: Parameters = [ "id" : email,
                                       "password" : password ]
        let headers: HTTPHeaders = [ HTTPHeaderKeys.contentType.rawValue : HTTPHeaderValues.applicationJSON.rawValue ]
        
        AF.request(loginURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers,
                   interceptor: interceptor)
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                print("✏️ UserManager - login() statusCode: \(statusCode)")
                
                switch statusCode {
    
                case 201:
                
                    do {
                        let json = try JSON(data: response.data!)
                        self.saveAccessTokens(from: json)
                        
                        User.shared.id = email
                        User.shared.password = password
                        User.shared.isLoggedIn = true
                        
                        completion(.success(true))
                        
                    } catch {
                        print("UserManager - login() catch error: \(error)")
                        completion(.failure(.E000))
                    }
                default:
                    
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    func loadOtherUsersProfile(userUID: String,
                               completion: @escaping (Result<LoadOtherUserProfileModel, NetworkError>) -> Void) {
        
        let url = loadUserProfileURL + "/\(userUID)"
        
        AF.request(url,
                   method: .get,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    
                    do {
                        let decodedData = try JSONDecoder().decode(LoadOtherUserProfileModel.self, from: response.data!)
                        print("✏️ User Manager - loadOtherUsersProfile() success")
                        completion(.success(decodedData))
                    } catch {
                        print("❗️ User Manager - loadOtherUsersProfile() decoding error \(error) ")
                        completion(.failure(.E000))
                    }
                    
                default:
                    print("❗️ loadOtherUsersProfile FAILED ")
                    let error = NetworkError.returnError(json: response.data!)
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 프로필 조회
    func loadUserProfile(completion: @escaping (Result<LoadProfileResponseModel, NetworkError>) -> Void) {
        
        AF.request(loadUserProfileURL,
                   method: .get,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    do {
                        let decodedData = try JSONDecoder().decode(LoadProfileResponseModel.self, from: response.data!)  
                        self.saveUserLoginInfo(with: decodedData)
                        
                        
                        print("✏️ User Manager - loadUserProfile() success")
                        
                        completion(.success(decodedData))
                        
                    } catch {
                        print("User Manager - loadUserProfile() catch error \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    print("loadUserProfile FAILED")
                    let error = NetworkError.returnError(json: response.data!)
                    completion(.failure(error))
                }
                
            }
    }
    
    //MARK: - 프로필 이미지 수정 (DB상)
    func updateUserProfileImage(with uid: String,
                                completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [
            "nickname": User.shared.nickname,
            "password": User.shared.password,
            "image": uid
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
                    let error = NetworkError.returnError(json: response.data!)
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
            "image": User.shared.profileImageUID
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
                    let error = NetworkError.returnError(json: response.data!)
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
            "image": User.shared.profileImageUID
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
                    let error = NetworkError.returnError(json: response.data!)
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 로그아웃
    func logOut(completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(logoutURL,
                   method: .delete,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    
                    User.shared.resetAllUserInfo()
                    print("logout success")
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("logout FAILED with error code: \(statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 비밀번호 찾기
    func findPassword(email: String,
                      completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [ "id" : email ]
        
        AF.request(findPasswordURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default    )
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("✏️ UserManager - findPassword SUCCESS")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ UserManager findPassword error statusCode: \(statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 회원 탈퇴
    func unregisterUser(completion: @escaping((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(unregisterURL,
                   method: .delete,
                   interceptor: interceptor)
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    
                    User.shared.resetAllUserInfo()
                    print("✏️ unregisterUser SUCCESS")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ unregisterUser failed with error code: \(statusCode), and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
                
            }
        
        
    }
    
}

//MARK: - 개인정보 저장 메서드

extension UserManager {
    
    func saveAccessTokens(from response: JSON) {
        
        let accessToken = response["accessToken"].stringValue
        let refreshToken = response["refreshToken"].stringValue
        
        User.shared.savedAccessToken = KeychainWrapper.standard.set(accessToken,
                                                                    forKey: Constants.KeyChainKey.accessToken)
        User.shared.savedRefreshToken = KeychainWrapper.standard.set(refreshToken,
                                                                     forKey: Constants.KeyChainKey.refreshToken)
        
    }
    
    func saveRefreshedAccessToken(from response: JSON) {
        
        let newAccessToken = response["accessToken"].stringValue
   
        User.shared.savedAccessToken = KeychainWrapper.standard.set(newAccessToken,
                                                                    forKey: Constants.KeyChainKey.accessToken)
    }
    
    func saveUserLoginInfo(with model: LoadProfileResponseModel) {
        
        User.shared.userUID = model.uid
        User.shared.email = model.email
        User.shared.nickname = model.nickname
        User.shared.profileImageUID = model.profileImageCode
    }

}


//MARK: - Validation Methods

extension UserManager {
    
    func checkIfProfileImageIsInCache() -> Bool {
        
        if let imageFromCache = profileImageCache.object(forKey: "profileImageCache" as AnyObject) as? UIImage {
            User.shared.profileImage = imageFromCache
            return true
        }
        return false
    }
}
