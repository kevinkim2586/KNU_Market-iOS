import Foundation
import Alamofire
import Security
import SwiftyJSON

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
            
            if let profileImage = model.image {
                multipartFormData.append(profileImage,
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
                            print("login success")
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
    
    //MARK: - 프로필 수정
    
    
    //TODO: - 프로필 정보 중 하나를 업데이트 하려면, 그리고 그 중에서 이미지를 업뎃하려면 uploadImage를 먼저해야함
    func updateUserProfileInfo(with newInfo: Any,
                               completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        // 만약 nickname 이나 password 를 변경하고자 한다면
        if let info = newInfo as? String {
            
            
        }
        else if let image = newInfo as? UIImage {
            
            self.uploadImage(with: image) { result in
                
                switch result {
                case .success(let imageID):
                    
                    print("User Manager - updateUserProfileInfo success in uploadImage")
                    
                case .failure(let error):
                    print("User Manager - updateUserProfileInfo .failure ACTIVATED with \(error.errorDescription)")
                    completion(.failure(error))
                }
               
            }
        }
        
        
    }
    

    
    
    //MARK: - 이미지 업로드
    func uploadImage(with image: UIImage,
                     completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = ["authentication" : User.shared.accessToken]
        
        AF.upload(multipartFormData: { multipartFormData in
            
            let imageData = image.jpegData(compressionQuality: 1)!
            
            multipartFormData.append(imageData,
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
                    completion(.success(imageID))
                    
                } catch {
                    print("UserManager - uploadImage() catch error \(error)")
                    completion(.failure(.E000))
                }
            default: completion(.failure(.E000))
            }
            
        }
    }
    
    
    func saveAccessTokens(from response: JSON) {
        
        User.shared.accessToken = response["accessToken"].stringValue
        User.shared.refreshToken = response["refreshToken"].stringValue
    }
    
    
    
}
