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
    
    func configurePostFilterOption(type: PostFilterOptions) {
        userDefaultsGenericService.set(key: UserDefaults.Keys.postFilterOptions, value: type.rawValue)
    }
    
    func configureUserAsVerifiedUser() {
        userDefaultsGenericService.set(key: UserDefaults.Keys.hasVerifiedEmail, value: true)
    }
    
    func saveAccessTokens(from response: LoginResponseModel) {
        _ = KeychainWrapper.standard.set(response.accessToken, forKey: K.KeyChainKey.accessToken)
        _ = KeychainWrapper.standard.set(response.refreshToken, forKey: K.KeyChainKey.refreshToken)
    }
    
    func saveUserProfileInfo(from model: LoadProfileResponseModel) {
        userDefaultsGenericService.set(key: UserDefaults.Keys.userUID, value: model.uid)
        userDefaultsGenericService.set(key: UserDefaults.Keys.userID, value: model.id)
        userDefaultsGenericService.set(key: UserDefaults.Keys.emailForPasswordLoss, value: model.emailForPasswordLoss)
        userDefaultsGenericService.set(key: UserDefaults.Keys.nickname, value: model.nickname)
        userDefaultsGenericService.set(key: UserDefaults.Keys.profileImageUID, value: model.profileImageUid)
        userDefaultsGenericService.set(key: UserDefaults.Keys.hasVerifiedEmail, value: model.isVerified)
    }
    
    func updateLocalUserInfo(type: UpdateUserInfoType, infoString: String) {
        switch type {
        case .nickname:
            userDefaultsGenericService.set(key: UserDefaults.Keys.nickname, value: infoString)
        case .fcmToken:
            userDefaultsGenericService.set(key: UserDefaults.Keys.fcmToken, value: infoString)
        case .profileImage:
            userDefaultsGenericService.set(key: UserDefaults.Keys.profileImageUID, value: infoString)
        case .id:
            userDefaultsGenericService.set(key: UserDefaults.Keys.userID, value: infoString)
        case .email:
            userDefaultsGenericService.set(key: UserDefaults.Keys.emailForPasswordLoss, value: infoString)
        default: break
        }
    }
    
    func resetAllUserInfo() {
        userDefaultsGenericService.resetAllUserInfo()
    }
}
