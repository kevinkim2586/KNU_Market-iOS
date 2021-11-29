import UIKit

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
            postViewModel: PostViewModel(
                itemManager: ItemManager(),
                chatManager: ChatManager(),
                userManager: UserManager()
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
            viewModel: ChatListViewModel(chatManager: ChatManager(), itemManager: ItemManager())
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
        
        let myPageVC = MyPageViewController(userManager: UserManager())
        myPageVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy)), tag: 0)
        let MyPageNavigationController = UINavigationController(rootViewController: myPageVC)
        
        MyPageNavigationController.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
        MyPageNavigationController.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
        MyPageNavigationController.navigationBar.tintColor = .black
        
        return MyPageNavigationController
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
}
