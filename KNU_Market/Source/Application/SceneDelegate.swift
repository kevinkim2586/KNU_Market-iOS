
import UIKit
import Moya
import Firebase
import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let userNotificationService: UserNotificationServiceType = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService.shared)
    let urlNavigator: URLNavigatorType = URLNavigator()
    let userDefaultsGenericService: UserDefaultsGenericServiceType = UserDefaultsGenericService()
    
    var coordinator = FlowCoordinator()
    lazy var appServices = AppServices()
    
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        guard let window = window else { return }

        window.windowScene = windowScene
        
        let appFlow = AppFlow(window: window, services: appServices)
        
        let isLoggedIn: Bool = userDefaultsGenericService.get(key: UserDefaults.Keys.isLoggedIn) ?? false
        
        if isLoggedIn == true {

            let appStepper = OneStepper(withSingleStep: AppStep.mainIsRequired)
            self.coordinator.coordinate(flow: appFlow, with: appStepper)

        } else {

            let appStepper = OneStepper(withSingleStep: AppStep.loginIsRequired)
            self.coordinator.coordinate(flow: appFlow, with: appStepper)
        }
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
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

//MARK: - Dynamic Link Handling Methods

extension SceneDelegate {
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        if let incomingURL = userActivity.webpageURL {
            let _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                guard error == nil else { return }
                if let dynamicLink = dynamicLink {
                    self.urlNavigator.handleIncomingDynamicLink(dynamicLink)
                }
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        guard let url = URLContexts.first?.url else {
            return
        }
        
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            urlNavigator.handleIncomingDynamicLink(dynamicLink)
        }
    }
}
