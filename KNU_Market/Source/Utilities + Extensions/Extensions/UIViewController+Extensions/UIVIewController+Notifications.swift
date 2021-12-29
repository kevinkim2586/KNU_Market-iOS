//
//  UIVIewController+Notifications.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit

//MARK: - Notification Related

extension UIViewController {

    @objc func getChatTabBadgeValue() {
        
        if let tabItems = tabBarController?.tabBar.items {
            
            let chatTabBarItem = tabItems[1]
            
            if User.shared.chatNotificationList.count == 0 {
                chatTabBarItem.badgeValue = nil
            } else {
                chatTabBarItem.badgeValue = "\(User.shared.chatNotificationList.count)"
            }
        }
    }
    
    // 최초 알림 허용 메시지
    func askForNotificationPermission() {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            
            guard granted else {
                
                User.shared.hasAllowedForNotification = false
                
                DispatchQueue.main.async {
                    self.presentAlertWithCancelAction(
                        title: "알림 받기를 설정해 주세요.👀",
                        message: "알림 받기를 설정하지 않으면 공구 채팅 알림을 받을 수 없어요. '확인'을 눌러 설정으로 이동 후 알림 켜기를 눌러주세요.😁"
                    ) { selectedOk in
                        if selectedOk {
                            UIApplication.shared.open(
                                URL(string: UIApplication.openSettingsURLString)!,
                                options: [:],
                                completionHandler: nil
                            )
                        }
                    }
                }
                return
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    User.shared.hasAllowedForNotification = true
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
