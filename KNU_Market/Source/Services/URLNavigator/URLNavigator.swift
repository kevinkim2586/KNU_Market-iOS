//
//  URLNavigator.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/06.
//

import UIKit
import FirebaseDynamicLinks

//MARK: - 알림을 탭하거나 Dynamic Link를 탭해서 들어왔을 때 적절하게 Navigation을 처리해주는 클래스.

final class URLNavigator: URLNavigatorType {

    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("❗️ Dynamic link has no url!")
            return
        }
        print("✅ incoming link parameter: \(url.absoluteString)")
        
        // 앱 실행이 안 되어있는 상태에서 링크 실행하면 동작 X -> 수정하기
        
        // Parse the link parameter
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else { return }
        
        if components.path == ComponentPath.post.rawValue {
            
            if let postIDQueryItem = queryItems.first(where: { $0.name == QueryItem.post.rawValue }) {
                
                guard let postUID = postIDQueryItem.value else { return }
        
                let postVC = PostViewController(
                    reactor: PostViewReactor(
                        pageId: postUID,
                        isFromChatVC: false,
                        postService: PostService(network: Network<PostAPI>(plugins: [AuthPlugin()])),
                        chatService: ChatService(
                            network: Network<ChatAPI>(plugins: [AuthPlugin()]),
                            userDefaultsGenericService: UserDefaultsGenericService()
                        ),
                        sharingService: SharingService(),
                        userDefaultsService: UserDefaultsGenericService()
                    )
                )
        
                guard let rootVC = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                    return
                }
                
                if let tabBarController = rootVC as? UITabBarController,
                   let navController = tabBarController.selectedViewController as? UINavigationController {
                    navController.pushViewController(postVC, animated: true)
                }
            }
        }
    }
    
    
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
