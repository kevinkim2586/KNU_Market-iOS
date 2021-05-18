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
    func register(with model: RegisterModel) {
        
        
        
    }
    
    //MARK: - 닉네임 중복 체크
    func checkDuplicate(nickname: String,
                        completion: @escaping (Result<Bool, > ->Void)) {
        
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
                            
                            if result == "true" { completion("true") }
                            else { completion("false") }
                        } catch {
                            print("UserManager - checkDuplicate() catch error: \(error)")
                            completion("error")
                        }
                    default:
                        completion("error")
                    }
                   }
    }
     
    //MARK: - 로그인
    func login() {
        
        
    
        
    }
    
    
    
    
}
