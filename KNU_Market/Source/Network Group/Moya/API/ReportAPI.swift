//
//  ReportAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import Moya

enum ReportAPI {
    case reportUser(model: ReportUserRequestDTO)
}

extension ReportAPI: BaseAPI {
    
    var path: String {
        switch self {
        case let .reportUser(model):
            return "report/\(model.postUID)"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .reportUser:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .reportUser(model):
            return model.parameters
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        default: return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
