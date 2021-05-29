import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

enum ProfileInfoType {
    
    case nickname
    case password
    case profileImage
}

class UserManager {
    
    //MARK: - Singleton
    static let shared: UserManager = UserManager()
    
    private init() {}
    
    //MARK: - API Request URLs
    let registerURL                 = "\(Constants.API_BASE_URL)auth"
    let loginURL                    = "\(Constants.API_BASE_URL)login"
    let checkDuplicateURL           = "\(Constants.API_BASE_URL)duplicate"
    
    let logoutURL                   = "\(Constants.API_BASE_URL)logout"
    let requestAccessTokenURL       = "\(Constants.API_BASE_URL)token"
    let findPasswordURL             = "\(Constants.API_BASE_URL)findpassword"
    let loadUserProfileURL          = "\(Constants.API_BASE_URL)auth"
    let userProfileUpdateURL        = "\(Constants.API_BASE_URL)auth"
    let requestMediaURL             = "\(Constants.API_BASE_URL)media/"
    let uploadImageURL              = "\(Constants.API_BASE_URL)media"
    
    
    //MARK: - 회원가입
    func register(with model: RegisterModel,
                  completion: @escaping ((Result<Bool, Error>) -> Void)) {
        
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
                completion(.success(true))
            default:
                let error = NetworkError.returnError(json: response.data!)
                completion(.failure(error))
            }
        }
    }
    
    
    //MARK: - 닉네임 중복 체크
    func checkDuplicate(nickname: String,
                        completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "id": nickname
        ]
        
        AF.request(checkDuplicateURL,
                   method: .get,
                   headers: headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    case 200:
                        do {
                            
                            let json = try JSON(data: response.data!)
                            let result = json["isDuplicate"].stringValue
                            
                            print("USER MANAGER - checkDuplicate Result: \(result)")
                            
                            if result == "true" {
                                completion(.success(true))
                            }
                            else {
                                completion(.success(false))
                            }
                            
                        } catch {
                            print("UserManager - checkDuplicate() catch error: \(error)")
                            completion(.failure(.E000))
                        }
                    default:
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
                   }
    }
    
    //MARK: - 로그인
    func login(id: String, password: String,
               completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
    
        let parameters: Parameters = [ "id":id, "password":password ]
        let headers: HTTPHeaders = [ "Content-Type": "application/json" ]
        
        AF.request(loginURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    
                    case 201:
                        do {
                            let json = try JSON(data: response.data!)
                            self.saveAccessTokens(from: json)
                            print("login success with API TOKEN: \(User.shared.accessToken)")
                            completion(.success(true))
                            
                        } catch {
                            print("UserManager - login() catch error: \(error)")
                            completion(.failure(.E000))
                        }
                    default:
                        print("login FAILED")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
                   }
    }
    
    
    
    
    //MARK: - 프로필 조회
    func loadUserProfile(completion: @escaping ((Result<LoadProfileResponseModel, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        AF.request(loadUserProfileURL,
                   method: .get,
                   headers: headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    case 201:
                        do {
                            
                            let decodedData = try JSONDecoder().decode(LoadProfileResponseModel.self, from: response.data!)
                            print("UserManager - loadUserProfile decodedData: \(decodedData)")
                            self.saveBasicUserInfo(with: decodedData)
                            print("User Manager - loadUserProfile() success")
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
    
    
    
    //MARK: - 파일 조회
    func requestMedia(from urlString: String,
                      completion: @escaping ((Result<Data?, NetworkError>) -> Void)) {
        
        let requestURL = requestMediaURL + urlString
        
        AF.request(requestURL,
                   method: .get).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    case 200:
                        completion(.success(response.data!))
                    default:
                        print("requestMedia FAILED")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
                   }
    }
    
    //MARK: - 프로필 이미지 수정 (DB상)
    func updateUserProfileImage(with uid: String,
                                completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
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
                   headers: headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    
                    case 201:
                        print("UserManager - updateUserProfileImage success")
                        completion(.success(true))
                        User.shared.profileImageCode = uid
                        
                    default:
                        print("UserManager - updateUserProfileImage failed default statement")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
                   }
    }
                                                       
                                                       
                                        
    //MARK: - 이미지 업로드
    func uploadImage(with image: Data,
                     completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]

        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(image,
                                     withName: "media",
                                     fileName: "newUserProfileImage.jpeg",
                                     mimeType: "image/jpeg")
            
        }, to: uploadImageURL,
        headers: headers).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 201:
                do {
                    
                    let json = try JSON(data: response.data!)
                    let imageID = json["uid"].stringValue
                    print("UserManager: newly updated profileImage UID: \(imageID)")
                    completion(.success(imageID))
                    
                } catch {
                    print("UserManager - uploadImage() catch error \(error)")
                    let error = NetworkError.returnError(json: response.data!)
                    completion(.failure(error))
                }
            default: completion(.failure(.E000))
            }
        }
    }
    
    //MARK: - 비밀번호 변경
    func updateUserPassword(with password: String,
                            completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        let parameters: Parameters = [
            "nickname": User.shared.nickname,
            "password": password,
            "image": User.shared.profileImageCode
        ]
        
        print("new password: \(password)")
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    
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
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        let parameters: Parameters = [
            "nickname": nickname,
            "password": User.shared.password,
            "image": User.shared.profileImageCode
        ]
        
        print("new nickname: \(nickname)")
        
        AF.request(userProfileUpdateURL,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers).responseJSON { response in
                    
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
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        AF.request(logoutURL,
                   method: .delete,
                   headers: headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    
                    case 201:
                        
                        User.shared.resetAllUserInfo()
                        completion(.success(true))
                    default:
                        print("logout FAILED")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
    }
        
    }
    

    
    
    
    
    //MARK: - 개인정보 저장 메서드
    
    func saveAccessTokens(from response: JSON) {
        
        let accessToken = response["accessToken"].stringValue
        let refreshToken = response["refreshToken"].stringValue
        
        User.shared.savedAccessToken = KeychainWrapper.standard.set(accessToken, forKey: Constants.KeyChainKey.accessToken)
        
        
        User.shared.savedRefreshToken = KeychainWrapper.standard.set(refreshToken, forKey: Constants.KeyChainKey.refreshToken)
        
    }
    
    func saveRefreshedAccessToken(from response: JSON) {
        
        let newAccessToken = response["accessToken"].stringValue
        
        // 확인 : 기존 accessCode 를 지우지 않고 바로 덮어씌울 수 있는지 확인해보기
        User.shared.savedAccessToken = KeychainWrapper.standard.set(newAccessToken, forKey: Constants.KeyChainKey.accessToken)
        
    }
    
    func saveBasicUserInfo(with model: LoadProfileResponseModel) {
        
        User.shared.id = model.id
        User.shared.nickname = model.nickname
        User.shared.profileImageCode = model.profileImageCode
    }
    

    
}
