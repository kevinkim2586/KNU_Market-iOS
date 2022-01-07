//
//  UserNotificationServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/06.
//

import Foundation
import UserNotifications

protocol UserNotificationServiceType: AnyObject {
    func saveReceivedNotification(with userInfo: [AnyHashable: Any])
    
    // 채팅 알림이 도착했을 때 해당 알림을 UserDefaults에 저장
    func addChatNotificationToUserDefaultsIfNeeded(with userInfo: [AnyHashable : Any])
    func saveNewlyReceivedChatNotifications()
    func notifyChatTabBadgeCountNeedsUpdate()
    func notifyChatListNeedsUpdate()
    func askForNotificationPermissionAtFirstLaunch()
}
