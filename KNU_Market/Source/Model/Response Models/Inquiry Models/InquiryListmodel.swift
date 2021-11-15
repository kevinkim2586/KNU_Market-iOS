//
//  InquiryListmodel.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/15.
//

import Foundation

struct InquiryListModel: Codable {
    var uid = String()
    var title = String()
    var content = String()
    var postUid = String()
    var reportedUserUid = String()
    var reportUserUid = String()
    var reportMediaUidFirst = String()
    var reportMediaUidSecond = String()
    var answer = String()
    var isArchived = Bool()
    var date = String()
    var delete_date = String()
}
