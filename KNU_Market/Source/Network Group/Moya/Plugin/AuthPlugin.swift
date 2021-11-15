//
//  AuthPlugin.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

import Moya

struct AuthPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        let token = User.shared.accessToken
        request.addValue(token, forHTTPHeaderField: "authentication")
        return request
    }
}
