import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class UserManager {
    
    //MARK: - Singleton
    static let shared: UserManager = UserManager()
    
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
    

    func loadUserProfileUsingUid(
        userUID: String,
        completion: @escaping (Result<LoadUserProfileUidModel, NetworkError>) -> Void
    ) {
        let url = loadUserProfileURL + "/\(userUID)"
        AF.request(
            url,
            method: .get,
            interceptor: interceptor
        )
            .validate()
            .responseJSON { response in
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200:
                    do {
                        let decodedData = try JSONDecoder().decode(LoadUserProfileUidModel.self, from: response.data!)
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
//    func loadUserProfile(completion: @escaping (Result<LoadProfileResponseModel, NetworkError>) -> Void) {
//        
//        AF.request(
//            loadUserProfileURL,
//            method: .get,
//            interceptor: interceptor
//        )
//            .validate()
//            .responseJSON { response in
//                guard let statusCode = response.response?.statusCode else { return }
//                switch statusCode {
//                case 200:
//                    do {
//                        let decodedData = try JSONDecoder().decode(LoadProfileResponseModel.self, from: response.data!)
//                        self.saveUserProfileInfo(with: decodedData)
//                        self.updateUserInfo(type: .fcmToken, infoString: UserRegisterValues.shared.fcmToken) { _ in }
//                        completion(.success(decodedData))
//                    } catch {
//                        print("❗️ User Manager - loadUserProfile() catch error \(error)")
//                        completion(.failure(.E000))
//                    }
//                default:
//                    print("❗️ loadUserProfile FAILED with statusCode: \(statusCode)")
//                    let error = NetworkError.returnError(json: response.data ?? Data())
//                    completion(.failure(error))
//                }
//            }
//    }
    

}

