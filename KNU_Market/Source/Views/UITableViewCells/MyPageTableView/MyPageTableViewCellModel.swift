//
//  MyPageTableViewCellModel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit

struct MyPageTableViewCellModel {
    
    let leftImage: UIImage
    let title: String
    let isNotificationBadgeHidden: Bool
    
    init(leftImage: UIImage, title: String, isNotificationBadgeHidden: Bool) {
        self.leftImage = leftImage
        self.title = title
        self.isNotificationBadgeHidden = isNotificationBadgeHidden
    }
}
