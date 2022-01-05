
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
        
        saveNewlyReceivedChatNotifications()
        
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
    
    func saveNewlyReceivedChatNotifications() {
        
        let previouslySavedChatNotifications: [String] = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.notificationList) ?? []
    
        var newChatNotifications: [String] = previouslySavedChatNotifications
        
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { notificationList in
            for notification in notificationList {
                let userInfo = notification.request.content.userInfo
                if let postUID = userInfo["postUid"] as? String {               // 받은 Notification payload 중에서 "postUid"에 해당하는 값만 받아오기
                    if !previouslySavedChatNotifications.contains(postUID) {   // 이전에 저장된 알림 목록에 포함이 안 된 것만 새로 append
                        newChatNotifications.append(postUID)
                    }
                }
            }
            UserDefaultsGenericService.shared.set(
                key: UserDefaults.Keys.notificationList,
                value: newChatNotifications
            )
        }
    
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)

        
    }
}

