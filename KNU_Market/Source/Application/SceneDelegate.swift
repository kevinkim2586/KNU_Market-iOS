
import UIKit
import Moya
import Firebase
import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let userNotificationService: UserNotificationService = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService.shared)
    let urlNavigator: URLNavigator = URLNavigator()
    
    
    
    var coordinator = FlowCoordinator()
    
    lazy var appServices = AppServices()
    
    
    
    
    
    
    
    
    
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        guard let window = window else { return }

        window.windowScene = windowScene
        
        
        let appFlow = AppFlow(window: window, services: appServices)
        let appStepper = OneStepper(withSingleStep: AppStep.mainIsRequired)
        
        self.coordinator.coordinate(flow: appFlow, with: appStepper)

        
            
        #warning("수정 필요!!!!!!")
        
        
//
//        if User.shared.isLoggedIn == true {
//            window?.rootViewController = UIHelper.createMainTabBarController()
//        } else {
//            let loginVC = LoginViewController(
//                reactor: LoginViewReactor(
//                    userService: UserService(network: Network<UserAPI>(), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared))
//                )
//            )
//            window?.rootViewController = loginVC
//        }
//        window?.makeKeyAndVisible()
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
                    self.urlNavigator.handleIncomingDynamicLink(dynamicLink)
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
            urlNavigator.handleIncomingDynamicLink(dynamicLink)
        } else {
            print("❗️ Maybe some other url?")
        }
    }
}
