
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        
        guard let window = self.window else {
            return
        }
        
        window.rootViewController = vc
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if User.shared.isLoggedIn == true {
            
            let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
            window?.rootViewController = mainTabBarController
        
        } else {
            
            let initialController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.initialVC)
            window?.rootViewController = initialController
        }
        
    
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("✏️ sceneDidDisconnect")

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("✏️ sceneDidBecomeActive")

        NotificationCenter.default.post(name: .getChat,
                                        object: nil)
        NotificationCenter.default.post(name: .getChatList,
                                        object: nil)
        NotificationCenter.default.post(name: .getBadgeValue,
                                        object: nil)
        
        ChatNotifications.list = UserDefaults.standard.stringArray(forKey: Constants.UserDefaultsKey.notificationList) ?? [String]()
        
        getDeliveredNotifications()
        
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("✏️ sceneWillResignActive")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("✏️ sceneWillEnterForeground")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("✏️ sceneDidEnterBackground")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

extension SceneDelegate {
    
    
    func getDeliveredNotifications() {
        
        let center = UNUserNotificationCenter.current()
        
        center.getDeliveredNotifications { notificationList in
            for notification in notificationList {
                let userInfo = notification.request.content.userInfo
                if let postUID = userInfo["postUid"] as? String {
                    if !User.shared.chatNotificationList.contains(postUID) {
                        ChatNotifications.list.append(postUID)
                    }
                }
            }
        }
    }
    
}

