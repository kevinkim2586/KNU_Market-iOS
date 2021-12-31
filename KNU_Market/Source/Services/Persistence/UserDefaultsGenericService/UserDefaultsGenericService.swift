//
//  UserDefaultsPersistenceService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit
import SwiftKeychainWrapper

final class UserDefaultsGenericService: UserDefaultsGenericServiceType {
    
    static let shared: UserDefaultsGenericService = UserDefaultsGenericService()
    
    private init() {}
    
    func set(key: String, value: Any?) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func get<T>(key: String) -> T? {
        let value = UserDefaults.standard.object(forKey: key)
        return value as? T
    }
    
    func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // 로그아웃, 회원탈퇴 시에 실행
    func resetAllUserInfo() {
        
        // Removes all User Default values
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Unregister for Push Notifications
        UIApplication.shared.unregisterForRemoteNotifications()
        
        // Removes data saved in KeyChain
        _ = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.accessToken)
        _ = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.refreshToken)
        
        // Removes all pending Chat Notifications
        ChatNotifications.list.removeAll()
        
        // 어플 알림 뱃지 0으로 설정
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        print("✅ ResetallUserInfo COMPLETE")
        print("✅ removed UserDefault Value Count: \(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)")
    }
}
