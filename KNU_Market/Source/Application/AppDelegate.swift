import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseMessaging
import UserNotificationsUI
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var disposeBag = DisposeBag()

    let gcmMessageIDKey = "gcm.message_id2"
    
    var window: UIWindow?
    
    // 사용자 알림 처리 및 저장 클래스
    let userNotificationService: UserNotificationService = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService.shared)
    
    // 알림에 따른 Navigation 처리 클래스
    let urlNavigator: URLNavigator = URLNavigator()
    
    let userService = UserService(
        network: Network<UserAPI>(plugins: [
            AuthPlugin()
        ]), userDefaultsPersistenceService: UserDefaultsPersistenceService(
            userDefaultsGenericService: UserDefaultsGenericService()
        )
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("✏️ didFinishLaunchingWithOptions")
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        // Observer for refresh token expiration
        NotificationCenterService.refreshTokenExpired.addObserver()
            .bind { _ in
                self.refreshTokenHasExpired()
            }
            .disposed(by: disposeBag)
        
        UNUserNotificationCenter.current().delegate = self
        
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❗️ Error fetching FCM registration token: \(error)")
            } else if let token = token {
                
                print("✏️ FCM Registration Token: \(token)")
                UserRegisterValues.shared.fcmToken = token
                User.shared.fcmToken = token
                
                
                let isLoggedIn: Bool = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.isLoggedIn) ?? false
                
                if isLoggedIn {
                    self.userService.updateUserInfo(type: .fcmToken, updatedInfo: token, profileImageData: nil)
                        .asObservable()
                        .subscribe(onNext: { _ in } )
                        .disposed(by: self.disposeBag)
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
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❗️didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
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

//MARK: - UNUserNotificationCenterDelegate

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        guard
            let isLoggedIn: Bool = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.isLoggedIn),
            isLoggedIn == true
        else { return }
              
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)            // 알림을 수신했음을 FireBase 에 알리는 함수
        
        print("✏️ willPresent userInfo: \(userInfo)")
        
        userNotificationService.saveReceivedNotification(with: userInfo)
        
        NotificationCenterService.getPreviousChats.post()
        NotificationCenterService.configureChatTabBadgeCount.post()
        
        completionHandler([[.alert, .sound, .badge]])
    }
    
    // 사용자가 알림을 탭하고 앱에 들어왔을 때 실행
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let userInfo = response.notification.request.content.userInfo
        print("✅ userInfo: \(userInfo)")
        
        Messaging.messaging().appDidReceiveMessage(userInfo)

        userNotificationService.saveReceivedNotification(with: userInfo)
        urlNavigator.handleReceivedNotification(with: userInfo)
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
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func configureIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        IQKeyboardManager.shared.disabledToolbarClasses = [
            ChatViewController.self,
            NickNameInputViewController.self,
            PasswordInputViewController.self,
            EmailVerificationViewController.self,
            CheckYourEmailViewController.self,
            IDInputViewController.self,
            EmailForLostPasswordViewController.self,SendUsMessageViewController.self
        ]
        
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
