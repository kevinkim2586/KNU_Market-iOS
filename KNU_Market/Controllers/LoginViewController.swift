import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    
    }
    
    
    
    


    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabbarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        mainTabbarController.modalPresentationStyle = .fullScreen
        
        self.present(mainTabbarController, animated: true, completion: nil)
        
        /*
        // after login is done, maybe put this in the login web service completion block
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        */
        
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    
}


//MARK: - UI Configuration

extension LoginViewController {
    
    func initialize() {
        
        initializeDelegates()
        
    }
    
    func initializeDelegates() {
        
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
}

