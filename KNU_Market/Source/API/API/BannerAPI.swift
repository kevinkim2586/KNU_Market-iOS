//
//  BannerAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import Foundation
import Moya

enum BannerAPI {
    case fetchBannerList
    case incrementBannerViewCount(bannerId: Int)
}

extension BannerAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .fetchBannerList:
            return "banners"
        case .incrementBannerViewCount(let bannerId):
            return "banners/\(bannerId)"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchBannerList, .incrementBannerViewCount:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        default:
            return .requestPlain
        }
    }
}
