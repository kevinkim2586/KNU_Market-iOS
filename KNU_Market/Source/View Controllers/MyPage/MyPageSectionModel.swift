//
//  MyPageSectionModel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/30.
//

import UIKit
import RxDataSources

struct MyPageCellData {
    let leftImageName: String
    let title: String
    var isNotificationBadgeHidden: Bool = true
}

struct MyPageSectionModel {
    var header: String
    var items: [MyPageCellData]
}

extension MyPageSectionModel: SectionModelType {
    
    init(original: MyPageSectionModel, items: [MyPageCellData]) {
        self = original
        self.items = items
    }
}
