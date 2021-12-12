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
    
}

extension UserAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .register:
            return "auth"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default:
            return [
                "Content-Type" : "multipart/form-data"
            ]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var task: Task {
        
        switch self {
        case let .register(model: model):
            
            var multipartData: [MultipartFormData] = []
            
            multipartData.append(MultipartFormData(provider: .data(model.id.data(using: .utf8)!), name: "id"))
            multipartData.append(MultipartFormData(provider: .data(model.id.data(using: .utf8)!), name: "password"))
            multipartData.append(MultipartFormData(provider: .data(model.id.data(using: .utf8)!), name: "nickname"))
            multipartData.append(MultipartFormData(provider: .data(model.id.data(using: .utf8)!), name: "fcmToken"))
            multipartData.append(MultipartFormData(provider: .data(model.id.data(using: .utf8)!), name: "email"))
        
            return .uploadMultipart(multipartData)
            
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .none
    }
}

