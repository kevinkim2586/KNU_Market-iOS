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
    case login(id: String, password: String)
    case loadUserProfileUsingUid(userUid: String)
    case loadUserProfile
    case sendFeedback(content: String)
    case unregisterUser
    case uploadStudentIdVerificationInformation(model: StudentIdVerificationDTO)
    case sendVerificationEmail(email: String)
    case updateUserInfo(type: UpdateUserInfoType, updatedInfo: String)
    case findUserId(option: FindUserInfoOption, studentEmail: String?, studentId: String?, studentBirthDate: String?)
    case findPassword(id: String)
    case checkLatestAppVersion
}

extension UserAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .register, .loadUserProfile, .unregisterUser, .updateUserInfo:
            return "auth"
        case .checkDuplication:
            return "duplicate"
        case .login:
            return "login"
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
        case .register, .uploadStudentIdVerificationInformation:
            return ["Content-Type" : "multipart/form-data"]
        case let .checkDuplication(type, infoString):
            switch type {
            case .id:
                return [ "id" : infoString ]
            case .email:
                return [ "email" : infoString]
            default: return nil
            }
        default:
            return ["Content-Type" : "application/json"]
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
            return .put
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .login(id, password):
            return [ "id" : id, "password" : password ]
        case let .checkDuplication(type, infoString):
            switch type {
            case .nickname:
                return [ "name" : infoString ]
            case .studentId:
                return [ "studentid" : infoString]
            default: return nil
            }
        case let .sendFeedback(content):
            return [ "content" : content ]
        case let .sendVerificationEmail(email):
            return [ "studentEmail": email ]
        case let .updateUserInfo(type, updatedInfo):
            return [ type.rawValue : updatedInfo ]
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
        case .checkDuplication:
            return URLEncoding.queryString
        default: return JSONEncoding.default
        }
    }
    
    var task: Task {
        
        switch self {
        case let .register(model: model):
            
            var multipartData: [MultipartFormData] = []
            
            multipartData.append(MultipartFormData(provider: .data(model.username.data(using: .utf8)!), name: "username"))
            multipartData.append(MultipartFormData(provider: .data(model.displayName.data(using: .utf8)!), name: "displayname"))
            multipartData.append(MultipartFormData(provider: .data(model.password.data(using: .utf8)!), name: "password"))
            multipartData.append(MultipartFormData(provider: .data(model.fcmToken.data(using: .utf8)!), name: "fcmToken"))
            multipartData.append(MultipartFormData(provider: .data(model.emailForPasswordLoss.data(using: .utf8)!), name: "email"))
        
            return .uploadMultipart(multipartData)
            
        case let .uploadStudentIdVerificationInformation(model: model):
            
            var multipartData: [MultipartFormData] = []
            
            multipartData.append(MultipartFormData(provider: .data(model.studentId.data(using: .utf8)!), name: "studentId"))
            multipartData.append(MultipartFormData(provider: .data(model.studentBirth.data(using: .utf8)!), name: "studentBirth"))
            multipartData.append(MultipartFormData(provider: .data(model.studentIdImageData), name: "media", fileName: "studentId.jpeg", mimeType: "image/jpeg"))
            
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
    case nickname       = "nickname"
    case password       = "password"
    case fcmToken       = "fcmToken"
    case profileImage   = "image"
    case id             = "id"
    case email          = "email"
}

enum CheckDuplicationType: String {
    case nickname       = "name"
    case studentId      = "studentId"
    case id             = "id"
    case email          = "email"       // 비밀번호 분실 시 임시 비밀번호를 발급 받을 이메일
}
