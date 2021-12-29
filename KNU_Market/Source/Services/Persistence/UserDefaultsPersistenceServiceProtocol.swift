//
//  UserDefaultsPersistenceServiceProtocol.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation

protocol UserDefaultsPersistenceServiceProtocol {
    func configureUserAsLoggedIn()
    func configurePostFilterOption(type: PostFilterOptions)
    func configureUserAsVerifiedUser()
    func saveAccessTokens(from response: LoginResponseModel)
    func saveUserProfileInfo(from model: LoadProfileResponseModel)
    func updateLocalUserInfo(type: UpdateUserInfoType, infoString: String)
    func resetAllUserInfo()
}
