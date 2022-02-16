//
//  AuthAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/16.
//

import Foundation
import Moya

enum AuthAPI {
    case refreshToken(_ refreshToken: String)
}

extension AuthAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .refreshToken:
            return "refresh"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .refreshToken(let refreshToken):
            return [ "Authorization" : "Bearer " + refreshToken ]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .refreshToken:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .refreshToken:
            return .requestPlain
        }
    }
}
