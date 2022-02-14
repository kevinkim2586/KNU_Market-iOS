//
//  UIVIewController+Notifications.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit

//MARK: - Notification Related

extension UIViewController {

    @objc func configureChatTabBadgeCount() {
        
        if let tabItems = tabBarController?.tabBar.items {
            
            let chatTabBarItem = tabItems[1]               //채팅 탭
            chatTabBarItem.badgeColor = UIColor(named: K.Color.appColor) ?? .systemRed
            
            let chatNotificationList: [String] = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.notificationList) ?? []
            
            chatTabBarItem.badgeValue = chatNotificationList.count == 0
            ? nil
            : "\(chatNotificationList.count)"
        }
    }
}
