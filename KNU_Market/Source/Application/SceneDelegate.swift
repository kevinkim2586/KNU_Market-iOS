
import UIKit
import Moya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
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

