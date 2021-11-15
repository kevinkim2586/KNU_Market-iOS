//
//  BaseAPI.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Moya
import Foundation

protocol BaseAPI: TargetType {}

extension BaseAPI {
    
    var baseURL: URL { URL(string: "https://knumarket.kro.kr:5051/api/v1")! }
    
    var headers: [String : String]? { nil }
    
    var method: Moya.Method { .get }
    
    var task: Task { .requestPlain }
    
    var sampleData: Data { Data() }
}
