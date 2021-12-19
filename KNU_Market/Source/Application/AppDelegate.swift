import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import UserNotificationsUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id2"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("✏️ didFinishLaunchingWithOptions")
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        // Observer for refresh token expiration
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTokenHasExpired),
            name: .refreshTokenExpired,
            object: nil
        )
        

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
          
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❗️ Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("✏️ FCM Registration Token: \(token)")
                UserRegisterValues.shared.fcmToken = token
                User.shared.fcmToken = token
                if User.shared.isLoggedIn {
                    UserManager.shared.updateUserInfo(type: .fcmToken, infoString: token) { _ in }
                }
            }
        }
        configureIQKeyboardManager()
        
        if #available(iOS 15, *) {
            configureUINavigationBarAppearance()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✏️ didRegisterForRemoteNotificationsWithDeviceToken")
        // Convert token to string (디바이스 토큰 값을 가져옵니다.)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

        print("APNs device token: \(deviceTokenString)")
        
        Messaging.messaging().apnsToken = deviceToken
        
        // Persist it in your backend in case it's new
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❗️ Failed to register: \(error)")
    }
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        print("✏️ didReceiveRemoteNotification")

        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("✏️ receivedMessage: \(userInfo)")
 
        completionHandler(.newData)
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("✏️ deviceToken: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    

}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if !User.shared.isLoggedIn { return }
        
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print("✏️ willPresent userInfo: \(userInfo)")
        
        if let postUID = userInfo["postUid"] as? String {
            if !User.shared.chatNotificationList.contains(postUID) {
                ChatNotifications.list.append(postUID)
            }
        }
        
        NotificationCenter.default.post(name: .getPreviousChats, object: nil)
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        
        completionHandler([[.alert, .sound, .badge]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        if let postUID = userInfo["postUid"] as? String {
            if !User.shared.chatNotificationList.contains(postUID) {
                ChatNotifications.list.append(postUID)
            }
        }
        completionHandler()
    }
}

//MARK: - Observers

extension AppDelegate {
    
    @objc func refreshTokenHasExpired() {
        
        guard let keywindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = keywindow.rootViewController else {
            return
        }
        rootVC.presentKMAlertOnMainThread(
            title: "로그인 세션 만료 🤔",
            message: "세션이 만료되었습니다. 다시 로그인해 주세요.",
            buttonTitle: "확인"
        )
        rootVC.popToLoginViewController()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func configureIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatViewController.self,
                                                           NickNameInputViewController.self,
                                                           PasswordInputViewController.self,
                                                           EmailInputViewController.self,
                                                           CheckEmailViewController.self,
                                                           IDInputViewController.self,
                                                           EmailForLostPasswordViewController.self,SendUsMessageViewController.self]
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatViewController.self)
    }
    
    func configureUINavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        let navigationBar = UINavigationBar()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        navigationBar.standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    
}
