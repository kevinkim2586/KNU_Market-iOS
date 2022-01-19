//
//  BannerModel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import Foundation

struct BannerModel: ModelType {
    
    let bannerId: Int
    let title: String
    let referenceUrl: String
    let media: MediaType
    
    enum CodingKeys: String, CodingKey {
        case bannerId, title, referenceUrl, media
    }
}
