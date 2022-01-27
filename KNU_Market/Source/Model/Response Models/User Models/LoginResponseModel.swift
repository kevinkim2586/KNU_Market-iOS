//
//  LoginResponseModel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation

struct LoginResponseModel: ModelType {
    let accessToken: String
    let refreshToken: String
}
