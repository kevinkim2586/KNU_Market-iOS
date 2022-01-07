//
//  URLNavigator.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/06.
//

import UIKit

final class URLNavigator {
    
    func handleReceivedNotification(with userInfo: [AnyHashable : Any]) {
        
        // 채팅 알림인지 아닌지 판별. 채팅이면 채팅을 보낸 사람 "sendName" key값이 날라오기 때문에 이걸로 판단 가능
        if let _ = userInfo["sendName"] as? String {
            navigateToChatListVC()
        }
        
        
    }
    
    private func navigateToChatListVC() {
        guard let rootVC = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
            return
        }
        
        if let tabBarController = rootVC as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
        
    }
}
