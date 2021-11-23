//
//  InquiryListmodel.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/15.
//

import Foundation

struct InquiryListModel: Codable {
    var uid = Int()
    var title : String?
    var content : String?
    var postUid = String()
    var reportedUserUid = String()
    var reportUserUid = String()
    var reportMediaUidFirst : String?
    var reportMediaUidSecond : String?
    var answer : String?
    var isArchived = Bool()
    var date = String()
    var delete_date : String?
    
    init(uid: Int,
         title: String?,
         content: String?,
         postUid : String,
         reportedUserUid: String,
         reportUserUid: String,
         reportMediaUidFirst: String?,
         reportMediaUidSecond: String?,
         answer: String?,
         isArchived: Bool,
         date: String,
         delete_date: String) {
        
        self.uid = uid
        self.title = title
        self.content = content
        self.postUid = postUid
        self.reportedUserUid = reportedUserUid
        self.reportUserUid = reportUserUid
        self.reportMediaUidFirst = reportMediaUidFirst
        self.reportMediaUidSecond = reportMediaUidSecond
        self.answer = answer
        self.isArchived = isArchived
        self.date = date
        self.delete_date = delete_date
    }
}
