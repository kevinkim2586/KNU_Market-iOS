import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class UserManager {
    
    //MARK: - Singleton
    static let shared: UserManager = UserManager()
    
    private init() {}
    
    //MARK: - API Request URLs
    //TODO: - EndPoint Router 로 아래 refactoring 진행
    let registerURL                 = "\(K.API_BASE_URL)auth"
    let loginURL                    = "\(K.API_BASE_URL)login"
    let checkDuplicationURL         = "\(K.API_BASE_URL)duplicate"
    let logoutURL                   = "\(K.API_BASE_URL)logout"
    let requestAccessTokenURL       = "\(K.API_BASE_URL)token"
    let findPasswordURL             = "\(K.API_BASE_URL)find/password"
    let loadUserProfileURL          = "\(K.API_BASE_URL)auth"
    let userProfileUpdateURL        = "\(K.API_BASE_URL)auth"
    let unregisterURL               = "\(K.API_BASE_URL)auth"
    let sendEmailURL                = "\(K.API_BASE_URL)verification/mail"
    let sendFeedbackURL             = "\(K.API_BASE_URL)report"
    let studentIdVerifyURL          = "\(K.API_BASE_URL)verification/card"
    let findIdURL                   = "\(K.API_BASE_URL)find/id"

    
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
            multipartFormData.append(Data(model.fcmToken.utf8)
                                     ,withName: "fcmToken")
            multipartFormData.append(Data(model.emailForPasswordLoss.utf8)
                                     ,withName: "email")
        }, to: registerURL,
        headers: model.headers).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 201:
                print("✏️ UserManager - register SUCCESS")
                completion(.success(true))
                User.shared.fcmToken = model.fcmToken
                User.shared.isAbsoluteFirstAppLaunch = true
                User.shared.postFilterOption = .showGatheringFirst
            default:
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ UserManager - register FAILED")
                completion(.failure(error))
            }
        }
    }
    
    
    //MARK: - 닉네임 및 아이디 중복 체크
    func checkDuplication(nickname: String? = nil,
                          id: String? = nil,
                          emailForPasswordLoss: String? = nil,
                          studentId: String? = nil,
                          completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
        
        var parameters: Parameters = [:]
        var headers: HTTPHeaders = [ HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.urlEncoded.rawValue ]
        
        if let nickname = nickname {
            parameters["name"] = nickname
        }
        if let studentId = studentId {
            parameters["studentid"] = studentId
        }
        if let id = id {
            headers.update(name: HTTPHeaderKeys.id.rawValue, value: id)
        }
        if let emailForPasswordLoss = emailForPasswordLoss {
            headers.update(name: HTTPHeaderKeys.email.rawValue, value: emailForPasswordLoss)
        }

        AF.request(checkDuplicationURL,
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
                        
                        let json = try JSON(data: response.data ?? Data())
                        let result = json["isDuplicate"].boolValue
                        result == false ? completion(.success(false)) : completion(.success(true))
                        
                    } catch {
                        print("UserManager - checkDuplicate() catch error: \(error)")
                        completion(.failure(.E000))
                    }
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 로그인
    func login(id: String,
               password: String,
               completion: @escaping ((Result<Bool, NetworkError>) ->Void)) {
        
        let parameters: Parameters = [ "id" : id,
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
                
                switch statusCode {
                
                case 201:
                    
                    do {
                        let json = try JSON(data: response.data ?? Data())
                        self.saveAccessTokens(from: json)
                        
                        User.shared.password = password
                        User.shared.isLoggedIn = true
                        UIApplication.shared.registerForRemoteNotifications()
                        
                        self.loadUserProfile { _ in }
                        
                        completion(.success(true))
                        
                    } catch {
                        completion(.failure(.E000))
                    }
                default:
                    
                    let error = NetworkError.returnError(json: response.data ?? Data())
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
                
                case 200:
                    
                    do {
                        let decodedData = try JSONDecoder().decode(LoadOtherUserProfileModel.self, from: response.data!)
                        print("✏️ User Manager - loadOtherUsersProfile() success")
                        completion(.success(decodedData))
                    } catch {
                        print("❗️ User Manager - loadOtherUsersProfile() decoding error \(error) ")
                        completion(.failure(.E000))
                    }
                    
                default:
                    print("❗️ loadOtherUsersProfile FAILED with statusCode: \(statusCode)")
                    let error = NetworkError.returnError(json: response.data ?? Data())
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
                
                case 200:
                    do {
                        let decodedData = try JSONDecoder().decode(LoadProfileResponseModel.self, from: response.data!)  
                        self.saveUserProfileInfo(with: decodedData)
                        
                        print("✏️ UserManager - loadUserProfile() success")
                        print("✏️ UserManager - DB FCM TOKEN: \(decodedData.fcmToken)")
                        
                        self.updateUserFCMToken(with: UserRegisterValues.shared.fcmToken)
                        
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ User Manager - loadUserProfile() catch error \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    print("❗️ loadUserProfile FAILED with statusCode: \(statusCode)")
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
                
            }
    }
    

    
    //MARK: - 건의사항 보내기 (유저 피드백)
    func sendFeedback(content: String,
                      completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let parameters: Parameters = [ "content" : content ]
        
        AF.request(sendFeedbackURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                case 201:
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ UserManager - sendFeedback statusCode: \(statusCode), reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    
    

    
    //MARK: - 회원 탈퇴
    func unregisterUser(completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
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
                    
                case 403:
                    print("❗️ 아직 참여 중인 공구가 존재")
                    completion(.failure(NetworkError.E403))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ unregisterUser failed with error code: \(statusCode), and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
                
            }
    }

}

