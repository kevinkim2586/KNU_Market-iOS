import Foundation
import SwiftKeychainWrapper
import SwiftyJSON

extension UserManager {
    
    //MARK: - 유저 Access Token 기기에 저장
    func saveAccessTokens(from response: JSON) {
        let accessToken = response["accessToken"].stringValue
        let refreshToken = response["refreshToken"].stringValue
        
        User.shared.savedAccessToken = KeychainWrapper.standard.set(accessToken,
                                                                    forKey: Constants.KeyChainKey.accessToken)
        User.shared.savedRefreshToken = KeychainWrapper.standard.set(refreshToken,
                                                                     forKey: Constants.KeyChainKey.refreshToken)
    }
    
    //MARK: - 만료된 Access Token 갱신 후 새로 발급된 토큰 기기에 저장
    func saveRefreshedAccessToken(from response: JSON) {
        let newAccessToken = response["accessToken"].stringValue
        User.shared.savedAccessToken = KeychainWrapper.standard.set(newAccessToken,
                                                                    forKey: Constants.KeyChainKey.accessToken)
    }
    
    //MARK: - 사용자 프로필 조회 후 기본적인 정보 저장
    func saveUserProfileInfo(with model: LoadProfileResponseModel) {
        User.shared.userUID = model.uid
        User.shared.userID = model.email     //email == id
        User.shared.nickname = model.nickname
        User.shared.profileImageUID = model.profileImageCode
        User.shared.isVerified = model.isVerified
    }
}
