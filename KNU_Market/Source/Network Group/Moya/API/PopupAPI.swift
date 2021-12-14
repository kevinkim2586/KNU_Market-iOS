//
//  PopupAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import Moya

enum PopupAPI {
    case fetchLatestPopup
    case incrementPopupViewCount(uid: Int)
}

extension PopupAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .fetchLatestPopup:
            return "popup"
        case let .incrementPopupViewCount(uid):
            return "popup/\(uid)"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchLatestPopup, .incrementPopupViewCount:
            return .get
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        default: return nil
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
