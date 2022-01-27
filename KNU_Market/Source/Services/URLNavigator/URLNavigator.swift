//
//  URLNavigator.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/06.
//

import UIKit

//MARK: - 알림을 탭하고 들어왔을 때 적절하게 Navigation을 처리해주는 클래스.

final class URLNavigator: URLNavigatorType {
    
    func handleReceivedNotification(with userInfo: [AnyHashable : Any]) {
        
        // 채팅 알림인지 아닌지 판별. 채팅이면 채팅을 보낸 사람 "sendName" key값이 날라오기 때문에 이걸로 판단 가능
        if let _ = userInfo[NotificationType.chat.rawValue] as? String {
            navigateToChatListVC()
        }
    }
    
    func navigateToChatListVC() {
        guard let rootVC = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        if let tabBarController = rootVC as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
    }
}
