//
//  CheckDuplicationType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/17.
//

import Foundation

enum CheckDuplicationType: String {
    case username       = "username"
    case displayName    = "displayname"
    case studentId      = "studentId"
    case email          = "email"       // 비밀번호 분실 시 임시 비밀번호를 발급 받을 이메일
}
