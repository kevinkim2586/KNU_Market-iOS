import UIKit
import SwiftKeychainWrapper

class User {

    //MARK: - Singleton
    static var shared: User = User()
    
    private init() {}
    
    //MARK: - Properties
    
    var userUID: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userUID) ?? "userUID 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.userUID)
        }
    }
    
    // 아래 없애는거 고려
    var id: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.userID) ?? "id 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.userID)
        }
    }
    
    var nickname: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.nickname) ?? "nickname 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.nickname)
        }
    }
    
    var password: String {
        get {
            let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: Constants.KeyChainKey.password)
            guard let password = retrievedPassword else {
                return "❗️ Invalid Password"
            }
            print("✏️ Password: \(password)")
            return password
        }
        set {
            self.savedPassword = KeychainWrapper.standard.set(newValue, forKey: Constants.KeyChainKey.password)
        }
    }
    
    var fcmToken: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.fcmToken) ?? "fcmToken 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.fcmToken)
        }
    }
    
    var email: String = ""

    
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.isLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.isLoggedIn)
        }
    }
    
    // 이메일 인증 완료 판별
    var hasVerifiedEmail: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.UserDefaultsKey.hasVerifiedEmail)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.hasVerifiedEmail)
        }
    }
    
    //MARK: - Access Token Related Properties
    
    var accessToken: String {
        
        get {
            let retrievedAccessToken: String? = KeychainWrapper.standard.string(forKey: Constants.KeyChainKey.accessToken)
            guard let accessToken = retrievedAccessToken else {
                return "❗️ Invalid AccessToken"
            }
            return accessToken
        }
    }
    
    var refreshToken: String {
        
        get {
            let retrievedRefreshToken: String? = KeychainWrapper.standard.string(forKey: Constants.KeyChainKey.refreshToken)
            guard let refreshToken = retrievedRefreshToken else {
                return "❗️ Invalid RefreshToken"
            }
            return refreshToken
        }
    }
        
    var savedAccessToken: Bool = false
    var savedRefreshToken: Bool = false
    var savedPassword: Bool = false
    
    //MARK: - User Profile Image Related Properties
    
    var profileImage: UIImage? {
        didSet {
            guard let imageData = profileImage?.jpegData(compressionQuality: 1.0) else {
                profileImageCache.removeAllObjects()
                return
            }
            self.profileImageData = imageData
        }
    }
    var profileImageData: Data?
    
    var profileImageUID: String {
        get {
            return UserDefaults.standard.string(forKey: Constants.UserDefaultsKey.profileImageUID) ?? "표시 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKey.profileImageUID)
        }
    }
    
    
    // 내가 직접 올린 공구글 PID 배열
    var userUploadedRoomPIDs: [String] = []
    
    // 내가 참여하고 있는 채팅방 PID 배열
    var joinedChatRoomPIDs: [String] = [ "__entireRoomPid" ]

    
    
}

//MARK: - Methods

extension User {

    func resetAllUserInfo() {

        id = ""
        nickname = ""
        email = ""
        profileImage = nil
        profileImageData = nil
        profileImageUID = ""
        
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.nickname)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.userID)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.profileImageUID)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.isLoggedIn)
        
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: Constants.KeyChainKey.accessToken)
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: Constants.KeyChainKey.refreshToken)
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: Constants.KeyChainKey.password)
        
        profileImageCache.removeAllObjects()
        
        print("✏️ resetAllUserInfo successful")
    }
    
}
