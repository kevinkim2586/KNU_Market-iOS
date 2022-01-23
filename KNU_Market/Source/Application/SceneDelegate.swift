
import UIKit
import Moya
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let userNotificationService: UserNotificationService = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService.shared)
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        if User.shared.isLoggedIn == true {
            window?.rootViewController = UIHelper.createMainTabBarController()
        } else {
            let loginVC = LoginViewController(
                reactor: LoginViewReactor(
                    userService: UserService(network: Network<UserAPI>(), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared))
                )
            )
            window?.rootViewController = loginVC
        }
        window?.makeKeyAndVisible()
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        userNotificationService.saveNewlyReceivedChatNotifications()
        
        NotificationCenterService.reconnectAndFetchFromLastChat.post()
        NotificationCenterService.getChatList.post()
        NotificationCenterService.configureChatTabBadgeCount.post()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("✏️ sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("✏️ sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("✏️ sceneDidEnterBackground")
    }
}



//MARK: - Dynamic Link Handling Methods

extension SceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        if let incomingURL = userActivity.webpageURL {
            print("✅ incomingURL: \(incomingURL)")
            
            let _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                
                guard error == nil else {
                    print("❗️ DynamicLink Error: \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    self.handleIncomingDynamicLink(dynamicLink)
                }
            }
        }
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            print("❗️ SceneDelegate - openURLContexts error obtaining url")
            return
        }
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            self.handleIncomingDynamicLink(dynamicLink)
        } else {
            print("❗️ Maybe some other url?")
        }
    }
    
    
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("❗️ Dynamic link has no url!")
            return
        }
        
        print("✅ incoming link parameter: \(url.absoluteString)")
        
        // Parse the link parameter
        
        
        
        // 앱 실행이 안 되어있는 상태에서 링크 실행하면 동작 X -> 수정하기
        
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else { return }
        
        if components.path == "/seePost" {
            
            if let postIDQueryItem = queryItems.first(where: { $0.name == "postUID"}) {
                
                guard let postUID = postIDQueryItem.value else { return }
                
                print("✅ postUID: \(postUID)")
                
                let postVC = NewPostViewController(
                    reactor: PostViewReactor(
                        pageId: postUID,
                        isFromChatVC: false,
                        postService: PostService(network: Network<PostAPI>(plugins: [AuthPlugin()])),
                        chatService: ChatService(
                            network: Network<ChatAPI>(plugins: [AuthPlugin()]),
                            userDefaultsGenericService: UserDefaultsGenericService()
                        ),
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
    

}
