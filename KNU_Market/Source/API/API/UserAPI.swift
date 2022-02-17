//
//  UserAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/07.
//

import Foundation
import Moya

enum UserAPI {
    case register(model: RegisterRequestDTO)
    case checkDuplication(type: CheckDuplicationType, infoString: String)
    case login(username: String, password: String)
    case loadUserProfileUsingUid(userUid: String)
    case loadUserProfile
    case sendFeedback(content: String)
    case unregisterUser
    case uploadStudentIdVerificationInformation(model: StudentIdVerificationDTO)
    case sendVerificationEmail(email: String)
    case updateUserInfo(type: UpdateUserInfoType, updatedInfo: String?, profileImageData: Data?)
    case findUserId(option: FindUserInfoOption, studentEmail: String?, studentId: String?, studentBirthDate: String?)
    case findPassword(id: String)
    case checkLatestAppVersion
}

extension UserAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .register:
            return "signup"
        case .login:
            return "login"
        case .loadUserProfile:
            return "users/profile"
        case .unregisterUser, .updateUserInfo:
            return "users"
        case .checkDuplication(let type, let infoString):
            return "users/\(type.rawValue)/\(infoString)"
        case let .loadUserProfileUsingUid(uid):
            return "auth/\(uid)"
        case .sendFeedback:
            return "report"
        case .uploadStudentIdVerificationInformation:
            return "verification/card"
        case .sendVerificationEmail:
            return "verification/mail"
        case .findUserId:
            return "find/id"
        case .findPassword:
            return "find/password"
        case .checkLatestAppVersion:
            return "version"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadStudentIdVerificationInformation, .updateUserInfo:
            return ["Content-Type" : "multipart/form-data"]
        default:
            return ["Content-Type":"application/x-www-form-urlencoded"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register, .login, .uploadStudentIdVerificationInformation, .sendVerificationEmail, .findUserId, .findPassword, .sendFeedback:
            return .post
        case .checkDuplication, .loadUserProfileUsingUid, .loadUserProfile, .checkLatestAppVersion:
            return .get
        case .unregisterUser:
            return .delete
        case .updateUserInfo:
            return .patch
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .register(model):
            return [ "username" : model.username, "displayname" : model.displayName, "password" : model.password, "fcmToken" : model.fcmToken, "email" : model.emailForPasswordLoss ]
        case let .login(username, password):
            return [ "username" : username, "password" : password ]
        case let .sendFeedback(content):
            return [ "content" : content ]
        case let .sendVerificationEmail(email):
            return [ "studentEmail": email ]
        case let .findUserId(option, studentEmail, studentId, studentBirthDate):
            switch option {
            case .schoolEmail:
                return [ "studentEmail": studentEmail! ]
            case .studentId:
                return ["studentId": studentId!, "studentBirth": studentBirthDate!]
            default: return nil
            }
        case let .findPassword(id):
            return [ "id" : id ]
        default: return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .register, .login:
            return URLEncoding.httpBody
        case .checkDuplication:
            return URLEncoding.queryString
        default: return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
        case let .uploadStudentIdVerificationInformation(model: model):
            
            var multipartData: [MultipartFormData] = []
            
            multipartData.append(MultipartFormData(provider: .data(model.studentId.data(using: .utf8)!), name: "studentId"))
            multipartData.append(MultipartFormData(provider: .data(model.studentBirth.data(using: .utf8)!), name: "studentBirth"))
            multipartData.append(MultipartFormData(provider: .data(model.studentIdImageData), name: "media", fileName: "studentId.jpeg", mimeType: "image/jpeg"))
            
            return .uploadMultipart(multipartData)
            
        case let .updateUserInfo(type, updatedInfo, profileImageData):

            var multipartData: [MultipartFormData] = []
            
            switch type {
            case .displayName:
                multipartData.append(MultipartFormData(provider: .data(updatedInfo!.data(using: .utf8)!), name: "displayname"))
            case .password:
                multipartData.append(MultipartFormData(provider: .data(updatedInfo!.data(using: .utf8)!), name: "password"))
            case .fcmToken:
                multipartData.append(MultipartFormData(provider: .data(updatedInfo!.data(using: .utf8)!), name: "fcmToken"))
            case .email:
                multipartData.append(MultipartFormData(provider: .data(updatedInfo!.data(using: .utf8)!), name: "email"))
            case .profileImage:
                multipartData.append(MultipartFormData(provider: .data(profileImageData!), name: "userProfile", fileName: "userProfileImage_\(UUID().uuidString).jpeg", mimeType: "image/jpeg"))
            }

            return .uploadMultipart(multipartData)
            
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
}


enum UpdateUserInfoType: String {
    case displayName    = "displayname"
    case password       = "password"
    case fcmToken       = "fcmToken"
    case profileImage   = "image"
    case email          = "email"
}

enum CheckDuplicationType: String {
    case username       = "username"
    case displayName    = "displayname"
    case studentId      = "studentId"
    case email          = "email"       // 비밀번호 분실 시 임시 비밀번호를 발급 받을 이메일
}
