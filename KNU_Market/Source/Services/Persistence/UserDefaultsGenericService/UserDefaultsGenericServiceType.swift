//
//  UserDefaultsPersistenceServiceProtocol.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation

protocol UserDefaultsGenericServiceType {
    func set(key: String, value: Any?)
    func get<T>(key: String) -> T?
    func remove(key: String)
    func resetAllUserInfo()
}
