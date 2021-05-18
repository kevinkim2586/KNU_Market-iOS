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
        
        UserManager.shared.login(id: "kevinkim2586@gmail.com", password: "123456789")
        

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        


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

