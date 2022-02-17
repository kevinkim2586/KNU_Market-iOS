//
//  UserServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import SwiftyJSON
import RxSwift

protocol UserServiceType: AnyObject {
    
    func register(with model: RegisterRequestDTO) -> Single<NetworkResult>
    func checkDuplication(type: CheckDuplicationType, infoString: String) -> Single<NetworkResultWithValue<DuplicateCheckModel>>
    
    @discardableResult
    func login(username: String, password: String) -> Single<NetworkResultWithValue<LoginResponseModel>>
    func loadUserProfileUsingUid(userUid: String) -> Single<NetworkResultWithValue<LoadUserProfileUidModel>>
    
    @discardableResult
    func loadUserProfile() -> Single<NetworkResultWithValue<LoadProfileResponseModel>>
    func sendFeedback(content: String) -> Single<NetworkResult>
    func unregisterUser() -> Single<NetworkResult>
    func uploadStudentIdVerificationInformation(model: StudentIdVerificationDTO) -> Single<NetworkResult>
    func sendVerificationEmail(email: String) -> Single<NetworkResult>
    
    @discardableResult
    func updateUserInfo(type: UpdateUserInfoType, updatedInfo: String?, profileImageData: Data?) -> Single<NetworkResultWithValue<LoadProfileResponseModel>>
        
    func findUserId(option: FindUserInfoOption, studentEmail: String?, studentId: String?, studentBirthDate: String?) -> Single<NetworkResultWithValue<FindIdModel>>
    func findPassword(id: String) -> Single<NetworkResultWithValue<FindPasswordModel>>
    
    func checkLatestAppVersion() -> Single<NetworkResultWithValue<LatestVersionModel>>
}
