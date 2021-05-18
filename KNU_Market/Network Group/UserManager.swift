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
    let requestUserProfileURL       = "\(Constants.API_BASE_URL)auth"
    let userProfileUpdateURL        = "\(Constants.API_BASE_URL)auth"
    
    
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
    func login(id: String, password: String) {
        
        //let JSONBody: JSON = [ "id":id, "password":password ]
        
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
                        print("login success")
                    default:
                        print("login FAILED")
                    }
                    

                    
                   }
        
        
        

        
    }
    
    
    
    
}
