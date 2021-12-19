import UIKit
import SPIndicator

struct UIHelper {
    
    static func createMainTabBarController() -> UITabBarController {
        
        // 탭바 생성
        let mainTabBarController = UITabBarController()
        mainTabBarController.tabBar.tintColor = UIColor(named: K.Color.appColor) ?? .systemPink
        mainTabBarController.tabBar.barTintColor = .white
        
        // 탭바 설정
        mainTabBarController.setViewControllers([
            createPostNavigationController(),
            createChatNavigationController(),
            createMyPageNavigationController()
        ], animated: true)
        return mainTabBarController
    }
    
    // 공구글 NavController 생성
    private static func createPostNavigationController() -> UINavigationController {
        
        let postListVC = PostListViewController(
            postViewModel: PostListViewModel(
                postManager: PostManager(),
                chatManager: ChatManager(),
                userManager: UserManager(),
                popupService: PopupService(network: Network<PopupAPI>())
            )
        )
        
        postListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: K.Images.homeSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
        let PostNavigationController = UINavigationController(rootViewController: postListVC)
        PostNavigationController.navigationBar.tintColor = .black
        
        return PostNavigationController
    }
    
    // 채팅 NavController 생성
    private static func createChatNavigationController() -> UINavigationController {
        let chatListVC = ChatListViewController(
            viewModel: ChatListViewModel(chatManager: ChatManager(), postManager: PostManager())
        )
        
        chatListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
        let ChatNavigationController = UINavigationController(rootViewController: chatListVC)
        ChatNavigationController.tabBarItem.image = UIImage(named: K.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
        ChatNavigationController.tabBarItem.selectedImage = UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate)
        ChatNavigationController.navigationBar.tintColor = UIColor.black
        
        return ChatNavigationController
    }
    
    // 마이페이지 NavController 생성
    private static func createMyPageNavigationController() -> UINavigationController {
        
        let myPageVC = MyPageViewController(viewModel: MyPageViewModel(userManager: UserManager(), mediaManager: MediaManager()))
        myPageVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy)), tag: 0)
        let MyPageNavigationController = UINavigationController(rootViewController: myPageVC)
        
        MyPageNavigationController.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
        MyPageNavigationController.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
        MyPageNavigationController.navigationBar.tintColor = .black
        
        return MyPageNavigationController
    }
    
    
    
    static func addNavigationBar(to view: UIView) -> UINavigationBar {
        
        let height: CGFloat
        
        if let statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top {
            print("✅ statusBarHeight: \(statusBarHeight)")
            height = statusBarHeight + 44
        } else {
            height = 75
        }
        
//        let height: CGFloat = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 44
        let width: CGFloat = UIScreen.main.bounds.width
        print("✅ width: \(width), height: \(height)")
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        navigationBar.backgroundColor = .systemGray
        
        return navigationBar
    }
    
    static func addNavigationBarWithAdditionalAction(in view: UIView, title: String = "", additionalBarButtonItem: UIBarButtonItem) -> UINavigationBar {
        
        let naviBar = UINavigationBar()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        naviBar.standardAppearance = appearance
        naviBar.scrollEdgeAppearance = appearance
    
        let naviItem = UINavigationItem(title: title)
        
        // X 버튼
        let dismissBarButtonItem =  UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(UIViewController.dismissVC)
        )
        dismissBarButtonItem.tintColor = .black
        additionalBarButtonItem.tintColor = .black
        
        
        naviItem.leftBarButtonItem = dismissBarButtonItem
        naviItem.rightBarButtonItem = additionalBarButtonItem
    
        naviBar.items = [naviItem]
        return naviBar
    }
    
    static func addNavigationBarWithDismissButton(in view: UIView, title: String = "") {
        
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        let naviBar = UINavigationBar(frame: .init(
            x: 0,
            y: statusBarHeight,
            width: view.frame.width,
            height: statusBarHeight)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        naviBar.standardAppearance = appearance
        naviBar.scrollEdgeAppearance = appearance
    
        let naviItem = UINavigationItem(title: title)
        
        // X 버튼
        let stopBarButtonItem =  UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(UIViewController.dismissVC)
        )
        stopBarButtonItem.tintColor = .black
    
        naviItem.rightBarButtonItem = stopBarButtonItem
        naviBar.items = [naviItem]
        view.addSubview(naviBar)
    }
    
    // ActionSheet 만들기
    static func createActionSheet(with actions: [UIAlertAction], title: String?) -> UIAlertController {
        
        let actionSheet = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.view.tintColor = .black
        
        actions.forEach { actionSheet.addAction($0) }
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        actionSheet.addAction(cancelAction)
        
        return actionSheet
    }
    
    static func presentWelcomePopOver(nickname: String) {
        guard let defaultImage = UIImage(systemName: "checkmark.circle") else { return }
        
        SPIndicator.present(
            title: "\(nickname)님",
            message: "환영합니다 🎉",
            preset: .custom(UIImage(systemName: "face.smiling")?.withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink, renderingMode: .alwaysOriginal) ?? defaultImage)
        )
    }
}
