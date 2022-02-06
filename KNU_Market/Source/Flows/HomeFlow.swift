//
//  HomeFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow

class HomeFlow: Flow {
    
    private let rootViewController = KMTabBarController()
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    init(services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .mainIsRequired:
            return navigateToMainHomeScreen()
        default:
            return .none
        }
    }
}

extension HomeFlow {
    
    private func navigateToMainHomeScreen() -> FlowContributors {
        
        let postFlow    = PostFlow(services: services)
        let chatFlow    = ChatFlow(services: services)
        let myPageFlow  = MyPageFlow(services: services)
        
        Flows.use(postFlow, chatFlow, myPageFlow, when: .created) { [unowned self] (postTab: UINavigationController, chatTab: UINavigationController, myPageTab: UINavigationController) in
            
            postTab.tabBarItem = UITabBarItem(title: "공동구매", image: UIImage(named: K.Images.homeSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
            postTab.tabBarItem.image = UIImage(named: K.Images.homeUnselected)?.withRenderingMode(.alwaysTemplate)
            postTab.tabBarItem.selectedImage = UIImage(named: K.Images.homeSelected)?.withRenderingMode(.alwaysTemplate)
            postTab.navigationBar.tintColor = .black
            
            
            chatTab.tabBarItem = UITabBarItem(title: "채팅방", image: UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
            chatTab.tabBarItem.image = UIImage(named: K.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
            chatTab.tabBarItem.selectedImage = UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate)
            chatTab.navigationBar.tintColor = .black
            
            
            myPageTab.tabBarItem = UITabBarItem(title: "마이페이지", image: UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
            myPageTab.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
            myPageTab.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
            myPageTab.navigationBar.tintColor = .black
            
            self.rootViewController.setViewControllers([postTab, chatTab, myPageTab], animated: true)
        }
        
        // 아래 3개의 Reactor는 모두 Stepper 역할 수행
        let postListReactor = PostListViewReactor(
            postService: services.postService,
            chatListService: services.chatListService,
            userService: services.userService,
            popupService: services.popupService,
            bannerService: services.bannerService,
            userDefaultsGenericService: services.userDefaultsGenericService,
            userNotificationService: services.userNotificationService
        )
       
        let chatListReactor = ChatListViewReactor(
            chatListService: services.chatListService,
            userDefaultsGenericService: services.userDefaultsGenericService
        )
        
        let myPageReactor = MyPageViewReactor(
            userService: services.userService,
            mediaService: services.mediaService,
            userDefaultsGenericService: services.userDefaultsGenericService
        )
        
        return .multiple(flowContributors: [
            .contribute(
                withNextPresentable: postFlow,
                withNextStepper: CompositeStepper(
                    steppers: [OneStepper(withSingleStep: AppStep.postListIsRequired), postListReactor]
                )
            ),
            .contribute(
                withNextPresentable: chatFlow,
                withNextStepper: CompositeStepper(
                    steppers: [OneStepper(withSingleStep: AppStep.chatListIsRequired), chatListReactor]
                )
            ),
            .contribute(
                withNextPresentable: myPageFlow,
                withNextStepper: CompositeStepper(
                    steppers: [OneStepper(withSingleStep: AppStep.myPageIsRequired), myPageReactor]
                )
            )
        ])
    }
}
