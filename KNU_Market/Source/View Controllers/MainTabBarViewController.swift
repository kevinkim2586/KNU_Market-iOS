import UIKit
import SnapKit

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let itemSB = UIStoryboard(name: StoryboardName.ItemList, bundle: nil)
        guard let itemVC = itemSB.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        let navigationController_1 = UINavigationController(rootViewController: itemVC)
        
        
        
        
        let chatSB = UIStoryboard(name: StoryboardName.ChatList, bundle: nil)
        guard let chatListVC = chatSB.instantiateViewController(withIdentifier: "ChatListViewController") as? ChatListViewController else { return }
        let navigationController_2 = UINavigationController(rootViewController: chatListVC)
        
        
       let myPageVC = MyPageViewController(userManager: UserManager())
        
    }
    
}
