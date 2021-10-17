import UIKit
import SwiftKeychainWrapper

class User {

    //MARK: - Singleton
    static var shared: User = User()
        
    //MARK: - Properties
    
    var userUID: String {
        get {
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.userUID) ?? "userUID 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.userUID)
        }
    }
    
    var userID: String {
        get {
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.userID) ?? "아이디 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.userID)
        }
    }
    
    var nickname: String {
        get {
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.nickname) ?? "닉네임 표시 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.nickname)
        }
    }
    
    var password: String {
        get {
            let retrievedPassword: String? = KeychainWrapper.standard.string(forKey: K.KeyChainKey.password)
            guard let password = retrievedPassword else {
                return "❗️ Invalid Password"
            }
            
            return password
        }
        set {
            self.savedPassword = KeychainWrapper.standard.set(newValue, forKey: K.KeyChainKey.password)
        }
    }
    
    var fcmToken: String {
        get {
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.fcmToken) ?? "fcmToken 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.fcmToken)
        }
    }
    
    var email: String = ""
    
    var emailForPasswordLoss: String {
        get {
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.emailForPasswordLoss) ?? "-"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.emailForPasswordLoss)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: K.UserDefaultsKey.isLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.isLoggedIn)
        }
    }
    
    var hasAllowedForNotification: Bool {
        get {
            return UserDefaults.standard.bool(forKey: K.UserDefaultsKey.hasAllowedForNotification)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.hasAllowedForNotification)
        }
        
    }
    
    // 이메일 인증 완료 판별
    var isVerified: Bool {
        get {
            return UserDefaults.standard.bool(forKey: K.UserDefaultsKey.hasVerifiedEmail)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.hasVerifiedEmail)
        }
    }
    
    var isNotFirstAppLaunch: Bool {
        get {
            return UserDefaults.standard.bool(forKey: K.UserDefaultsKey.isNotFirstAppLaunch)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.isNotFirstAppLaunch)
        }
    }
    
    //MARK: - Access Token Related Properties
    
    var accessToken: String {
        
        get {
            let retrievedAccessToken: String? = KeychainWrapper.standard.string(forKey: K.KeyChainKey.accessToken)
            guard let accessToken = retrievedAccessToken else {
                return "❗️ Invalid AccessToken"
            }
            return accessToken
        }
    }
    
    var refreshToken: String {
        
        get {
            let retrievedRefreshToken: String? = KeychainWrapper.standard.string(forKey: K.KeyChainKey.refreshToken)
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
            return UserDefaults.standard.string(forKey: K.UserDefaultsKey.profileImageUID) ?? "표시 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.profileImageUID)
        }
    }
    
    
    // 내가 직접 올린 공구글 PID 배열
    var userUploadedRoomPIDs: [String] = []
    
    // 내가 참여하고 있는 채팅방 PID 배열
    var joinedChatRoomPIDs: [String] = []

    
    var chatNotificationList: [String] {
        get {
            let list = UserDefaults.standard.stringArray(forKey: K.UserDefaultsKey.notificationList) ?? [String]()
            return list
        }
    }
    
    var bannedPostUploaders: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: K.UserDefaultsKey.bannedPostUploaders) ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.bannedPostUploaders)
        }
    }
    
    var bannedChatMembers: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: K.UserDefaultsKey.bannedChatUsers) ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: K.UserDefaultsKey.bannedChatUsers)
        }
    }
    
    //MARK: - User Settings
    
    var postFilterOption: PostFilterOptions {
        get {
            guard let filterOption = UserDefaults.standard.object(
                forKey: K.UserDefaultsKey.postFilterOptions
            ) as? String else { return .showAll }
            
            return PostFilterOptions(rawValue: filterOption) ?? .showAll
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: K.UserDefaultsKey.postFilterOptions)
        }
    }
}

//MARK: - Methods

extension User {

    func resetAllUserInfo() {
        
        UIApplication.shared.unregisterForRemoteNotifications()

        nickname = ""
        email = ""
        profileImage = nil
        profileImageData = nil
        profileImageUID = ""
        
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.nickname)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.profileImageUID)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.userUID)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.emailForPasswordLoss)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.fcmToken)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.hasAllowedForNotification)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.hasVerifiedEmail)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.bannedPostUploaders)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.bannedChatUsers)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.notificationList)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.isNotFirstAppLaunch)
        UserDefaults.standard.removeObject(forKey: K.UserDefaultsKey.postFilterOptions)
    
        
        ChatNotifications.list.removeAll()

        let _: Bool = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.accessToken)
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.refreshToken)
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.password)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        profileImageCache.removeAllObjects()
        
        print("✏️ resetAllUserInfo successful")
    }
    
}
