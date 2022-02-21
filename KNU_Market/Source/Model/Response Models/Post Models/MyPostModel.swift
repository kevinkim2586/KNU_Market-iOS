//
//  MyPostModel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/21.
//

import Foundation

struct MyPostModel: ModelType {
    
    let postId: String
    let title: String
    let location: Int?
    let headCount: Int
    let currentHeadCount: Int
    let createdAt: String
    let recruitedAt: String?
    let isRecruited: Int
    let price: Int?
    let shippingFee: Int?
    let createdBy: CreatedBy
    let postFile: FileInfo?
    
    enum CodingKeys: String, CodingKey {
        case postId, title, location, headCount, currentHeadCount, createdAt, recruitedAt, isRecruited, price, shippingFee, createdBy, postFile
    }
}
