//
//  UserService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import SwiftyJSON
import RxSwift
import SwiftKeychainWrapper


final class UserService: UserServiceType {
    
    fileprivate let network: Network<UserAPI>
    
    init(network: Network<UserAPI>) {
        self.network = network
    }
    
    func register(with model: RegisterRequestDTO) -> Single<NetworkResult> {
        return network.requestWithoutMapping(.register(model: model))
            .map { result in
                switch result {
                case .success:
                    return .success
                case let .error(error):
                    return .error(error)
                }
            }
    }
    
    func checkDuplication(type: CheckDuplicationType, infoString: String) -> Single<NetworkResultWithValue<DuplicateCheckModel>> {
        return network.requestObject(.checkDuplication(type: type, infoString: infoString), type: DuplicateCheckModel.self)
    }
    
    @discardableResult
    func login(id: String, password: String) -> Single<NetworkResultWithValue<LoginResponseModel>> {
        
        return network.requestObject(.login(id: id, password: password), type: LoginResponseModel.self)
            .map { [weak self] result in
                switch result {
                case .success(let loginResponseModel):
                    self?.saveAccessTokens(from: loginResponseModel)
                    User.shared.isLoggedIn = true
                    User.shared.postFilterOption = .showGatheringFirst
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.loadUserProfile()
                    return .success(loginResponseModel)
                    
                case .error(let error):
                    return .error(error)
                    
                }
            }
    }
    
    func loadUserProfileUsingUid(userUid: String) -> Single<NetworkResultWithValue<LoadUserProfileUidModel>> {
        
        return network.requestObject(.loadUserProfileUsingUid(userUid: userUid), type: LoadUserProfileUidModel.self)
            .map { result in
                switch result {
                case .success(let model):
                    return .success(model)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    @discardableResult
    func loadUserProfile() -> Single<NetworkResultWithValue<LoadProfileResponseModel>> {
        
        return network.requestObject(.loadUserProfile, type: LoadProfileResponseModel.self)
            .map { [weak self] result in
                switch result {
                case .success(let userModel):
                    self?.saveUserProfileInfo(with: userModel)
                    self?.updateUserInfo(type: .fcmToken, updatedInfo: UserRegisterValues.shared.fcmToken)
                    return .success(userModel)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func sendFeedback(content: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.sendFeedback(content: content))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func unregisterUser() -> Single<NetworkResult> {
        
        return network.request(.unregisterUser)
            .map {
                switch $0.statusCode {
                case 201:
                    self.resetAllUserInfo()
                    return .success
                case 403:   //  아직 참여 중인 공구가 존재함을 사용자에게 알림 (참여 중인게 있으면 모두 "나가기" 후 회원 탈퇴 가능)
                    return .error(.E403)
                default:
                    return .success
                }
            }
    }
    
    func uploadStudentIdVerificationInformation(model: StudentIdVerificationDTO) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.uploadStudentIdVerificationInformation(model: model))
            .map { result in
                switch result {
                case .success:
                    User.shared.isVerified = true
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func sendVerificationEmail(email: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.sendVerificationEmail(email: email))
            .map { result in
                switch result {
                case .success:
                    User.shared.isVerified = true
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    @discardableResult
    func updateUserInfo(type: UpdateUserInfoType, updatedInfo: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.updateUserInfo(type: type, updatedInfo: updatedInfo))
            .map { [weak self] result in
                switch result {
                case .success:
                    self?.updateLocalUserInfo(type: type, infoString: updatedInfo)
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func findUserId(
        option: FindUserInfoOption,
        studentEmail: String? = nil,
        studentId: String? = nil,
        studentBirthDate: String? = nil
    ) -> Single<NetworkResultWithValue<FindIdModel>> {
        
        return network.requestObject(.findUserId(option: option, studentEmail: studentEmail, studentId: studentId, studentBirthDate: studentBirthDate), type: FindIdModel.self)
            .map { result in
                switch result {
                case .success(let model):
                    return .success(model)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    
    func findPassword(id: String) -> Single<NetworkResultWithValue<FindPasswordModel>> {
        
        return network.requestObject(.findPassword(id: id), type: FindPasswordModel.self)
            .map { result in
                switch result {
                case .success(let model):
                    return .success(model)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    
    func saveAccessTokens(from response: LoginResponseModel) {
        User.shared.savedAccessToken = KeychainWrapper.standard.set(response.accessToken, forKey: K.KeyChainKey.accessToken)
        User.shared.savedRefreshToken = KeychainWrapper.standard.set(response.refreshToken, forKey: K.KeyChainKey.refreshToken)
    }
    
    func saveRefreshedAccessToken(from response: JSON) {
        let newAccessToken = response["accessToken"].stringValue
        User.shared.savedAccessToken = KeychainWrapper.standard.set(newAccessToken, forKey: K.KeyChainKey.accessToken)
    }
    
    func saveUserProfileInfo(with model: LoadProfileResponseModel) {
        User.shared.userUID = model.uid
        User.shared.userID = model.id            //email == id
        User.shared.emailForPasswordLoss = model.emailForPasswordLoss
        User.shared.nickname = model.nickname
        User.shared.profileImageUID = model.profileImageCode
        User.shared.isVerified = model.isVerified
    }
    
    func updateLocalUserInfo(type: UpdateUserInfoType, infoString: String) {
        
        switch type {
        case .nickname:
            User.shared.nickname = infoString
        case .password:
            User.shared.password = infoString
        case .fcmToken:
            if infoString != UserRegisterValues.shared.fcmToken {
                self.updateUserInfo(type: .fcmToken, updatedInfo: UserRegisterValues.shared.fcmToken)
            } else { User.shared.fcmToken = infoString }
        case .profileImage:
            User.shared.profileImageUID = infoString
        case .id:
            User.shared.userID = infoString
        case .email:
            User.shared.emailForPasswordLoss = infoString
        }
    }
    
    func resetAllUserInfo() {
        User.shared.resetAllUserInfo()
    }
}
