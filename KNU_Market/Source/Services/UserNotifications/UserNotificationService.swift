//
//  UserNotificationService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/06.
//

import UIKit
import UserNotifications

enum NotificationType: String {
    case chat = "sendName"
    case post = "postUid"
}

final class UserNotificationService: UserNotificationServiceType {
    
    static let shared = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService.shared)
    
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    init(userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.userDefaultsGenericService = userDefaultsGenericService
    }
    
    // 도착하는 모든 알림을 여기서 처리
    func saveReceivedNotification(with userInfo: [AnyHashable: Any]) {
        
        // 우선 광고성 알림이 아닌 채팅 알림임을 판별. 채팅을 보내면 채팅 발신자의 정보가 함께 날라오기 때문에 sendName 키로 채팅 알림인지 아닌지를 판별
        if let _ = userInfo[NotificationType.chat.rawValue] as? String{
            addChatNotificationToUserDefaultsIfNeeded(with: userInfo)
        }
        
        // 그 외 다른 종류의 NotificationType에 대응해야한다면 옵셔널 바인딩으로 처리

    }
    
    // 사용자가 도착한 채팅 알림을 탭하고 앱에 들어왔을 때 해당하는 postUID 를 UserDefaults에 저장
    func addChatNotificationToUserDefaultsIfNeeded(with userInfo: [AnyHashable : Any]) {
        
        var previouslySavedChatNotifications: [String] = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.notificationList) ?? []
        print("✅ previouslySavedChatNotifications: \(previouslySavedChatNotifications)")
        
        if let postUID = userInfo[NotificationType.chat.rawValue] as? String {
            
            print("✅ postUID: \(postUID)")
            
            if !previouslySavedChatNotifications.contains(postUID) {
                previouslySavedChatNotifications.append(postUID)
                
                print("✅ after appending: \(previouslySavedChatNotifications)")
                userDefaultsGenericService.set(
                    key: UserDefaults.Keys.notificationList,
                    value: previouslySavedChatNotifications
                )
                notifyChatTabBadgeCountNeedsUpdate()
                notifyChatListNeedsUpdate()
            }
         
        }
    }

    // 앱이 Background 상태에 있다가 다시 들어왔을 때 그동안 쌓인 Chat Notification을 UserDefaults에 저장하는 함수.
    // 저장 이후 Notification Center 를 통해 값이 업데이트 됐음을 업데이트 -> UI를 적절하게 업데이트
    func saveNewlyReceivedChatNotifications() {
        
        let previouslySavedChatNotifications: [String] = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.notificationList) ?? []
    
        var newChatNotifications: [String] = previouslySavedChatNotifications
                
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notificationList in
            for notification in notificationList {
                let userInfo = notification.request.content.userInfo
                if let postUID = userInfo[NotificationType.post.rawValue] as? String {      // 받은 Notification payload 중에서 "postUid"에 해당하는 값만 받아오기
                    if !previouslySavedChatNotifications.contains(postUID) {                // 이전에 저장된 알림 목록에 포함이 안 된 것만 새로 append
                        newChatNotifications.append(postUID)
                    }
                }
            }
            UserDefaultsGenericService.shared.set(
                key: UserDefaults.Keys.notificationList,
                value: newChatNotifications
            )
        }
        notifyChatTabBadgeCountNeedsUpdate()
        notifyChatListNeedsUpdate()
    }
    
    func notifyChatTabBadgeCountNeedsUpdate() {
        NotificationCenterService.configureChatTabBadgeCount.post()
    }
    
    func notifyChatListNeedsUpdate() {
        NotificationCenterService.updateChatList.post()
    }
    
    // 최초 알림 허용 메시지
    func askForNotificationPermissionAtFirstLaunch() {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            
            guard granted else {
                
                UserDefaultsGenericService.shared.set(
                    key: UserDefaults.Keys.hasAllowedForNotification,
                    value: false
                )
                
                guard let rootVC = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                    return
                }
                
                if let postListVC = rootVC as? PostListViewController {
                    
                    postListVC.presentAlertWithCancelAction(
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


