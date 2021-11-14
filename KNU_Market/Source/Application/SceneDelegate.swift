
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }
        
        if User.shared.isLoggedIn == true {
            window?.rootViewController = UIHelper.createMainTabBarController()
            window?.makeKeyAndVisible()
        } else {
            let initialController = InitialViewController(userManager: UserManager())
            window?.rootViewController = initialController
        }
    }
    

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
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

