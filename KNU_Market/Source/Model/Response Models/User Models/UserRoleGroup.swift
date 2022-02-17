//
//  UserRoleGroup.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/17.
//

import Foundation

enum UserRoleGroupType: String {
    case temporary = "TEMPORARY"      // 학생 인증을 마치지 않은 유저
    case common    = "COMMON"         // 학생 인증을 마친 유저
    case admin     = "ADMIN"
    case partners  = "PARTNERS"       // 파트너스 (자영업자)
}

struct UserRoleGroup: ModelType {
    let userRoleCode: String
    enum CodingKeys: String, CodingKey {
        case userRoleCode
    }
}
