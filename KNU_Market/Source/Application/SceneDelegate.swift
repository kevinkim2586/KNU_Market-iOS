
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("✏️ Scene Delegate - willConnectTo")

        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if User.shared.isLoggedIn == true {
            let mainTabBarController = storyboard.instantiateViewController(identifier: K.StoryboardID.tabBarController)
            window?.rootViewController = mainTabBarController
        } else {
//            let initialController = storyboard.instantiateViewController(identifier: K.StoryboardID.initialVC)
            let initialController = InitialViewController(userManager: UserManager())
            window?.rootViewController = initialController
            print("✏️ rootViewcontroler")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("✏️ sceneDidDisconnect")

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("✏️ sceneDidBecomeActive")

        NotificationCenter.default.post(
            name: .reconnectAndFetchFromLastChat,
            object: nil
        )
        NotificationCenter.default.post(
            name: .getChatList,
            object: nil
        )
        NotificationCenter.default.post(
            name: .getBadgeValue,
            object: nil
        )
        
        ChatNotifications.list = UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.notificationList) ?? [String]()
        
        getDeliveredNotifications()

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

