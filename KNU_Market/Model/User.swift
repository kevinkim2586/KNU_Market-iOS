import UIKit
import SwiftKeychainWrapper

class User {

    //MARK: - Singleton
    static var shared: User = User()
    
    private init() {}
    
    var id: String = ""
    
    var nickname: String = ""
    
    var password: String = ""
    
    var email: String = ""
    
    var accessToken: String {
        
        get {
            let retrievedAccessToken: String? = KeychainWrapper.standard.string(forKey: Constants.KeyChainKey.accessToken)
            guard let accessToken = retrievedAccessToken else {
                return "Invalid AccessToken"
            }
            return accessToken

        }
    }
    
    var refreshToken: String {
        
        get {
            let retrievedRefreshToken: String? = KeychainWrapper.standard.string(forKey: Constants.KeyChainKey.refreshToken)
            guard let refreshToken = retrievedRefreshToken else {
                return "Invalid RefreshToken"
            }
            return refreshToken
            
        }
    }
        
        
    var savedAccessToken: Bool = false
    
    var savedRefreshToken: Bool = false
    
    var profileImage: UIImage? {
        
        didSet {
            guard let imageData = profileImage?.jpegData(compressionQuality: 1.0) else { return }
            self.profileImageData = imageData
        }
    }
    var profileImageData: Data?
    
    var profileImageCode: String = ""
    
    
    func resetAllUserInfo() {
        
        id = ""
        nickname = ""
        password = ""
        email = ""
        profileImage = nil
        profileImageData = nil
        profileImageCode = ""
    
    }
    
    
}
