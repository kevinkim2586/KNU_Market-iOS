//
//  UserDefaultsPersistenceService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import SwiftKeychainWrapper

final class UserDefaultsPersistenceService: UserDefaultsPersistenceServiceType {
    
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    init(userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.userDefaultsGenericService = userDefaultsGenericService
    }
    
    func configureUserAsLoggedIn() {
        userDefaultsGenericService.set(key: UserDefaults.Keys.isLoggedIn, value: true)
    }
    
    func configureUserAsVerifiedUser() {
        userDefaultsGenericService.set(key: UserDefaults.Keys.userRoleGroup, value: UserRoleGroupType.common.rawValue)
    }
    
    func saveAccessTokens(from response: LoginResponseModel) {
        
        userDefaultsGenericService.set(key: UserDefaults.Keys.accessToken, value: response.accessToken)
        userDefaultsGenericService.set(key: UserDefaults.Keys.refreshToken, value: response.refreshToken)
        
//        _ = KeychainWrapper.standard.set(response.accessToken, forKey: K.KeyChainKey.accessToken)
//        _ = KeychainWrapper.standard.set(response.refreshToken, forKey: K.KeyChainKey.refreshToken)
    }
    
    func saveUserProfileInfo(from model: LoadProfileResponseModel) {
        userDefaultsGenericService.set(key: UserDefaults.Keys.userUID, value: model.userUid)
        userDefaultsGenericService.set(key: UserDefaults.Keys.username, value: model.username)
        userDefaultsGenericService.set(key: UserDefaults.Keys.displayName, value: model.displayName)
        userDefaultsGenericService.set(key: UserDefaults.Keys.emailForPasswordLoss, value: model.email)
        userDefaultsGenericService.set(key: UserDefaults.Keys.bannedTo, value: model.bannedTo)
        userDefaultsGenericService.set(key: UserDefaults.Keys.profileImageUrl, value: model.profileUrl)
        userDefaultsGenericService.set(key: UserDefaults.Keys.userRoleGroup, value: model.userRoleGroup.userRoleCode)
    }
    
    func updateLocalUserInfo(type: UpdateUserInfoType, infoString: String?) {
        guard let infoString = infoString else { return }
        switch type {
        case .displayName:
            userDefaultsGenericService.set(key: UserDefaults.Keys.displayName, value: infoString)
        case .fcmToken:
            userDefaultsGenericService.set(key: UserDefaults.Keys.fcmToken, value: infoString)
        case .profileImage:
            userDefaultsGenericService.set(key: UserDefaults.Keys.profileImageUrl, value: infoString)
        case .email:
            userDefaultsGenericService.set(key: UserDefaults.Keys.emailForPasswordLoss, value: infoString)
        default: break
        }
    }
    
    func resetAllUserInfo() {
        userDefaultsGenericService.resetAllUserInfo()
    }
}
