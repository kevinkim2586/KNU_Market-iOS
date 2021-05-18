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
        
        guard let id = idTextField.text, let password = passwordTextField.text else {
            return
        }
        guard id.count > 0, password.count > 0 else { return }
    
        
        UserManager.shared.login(id: id, password: password) { result in
            
            switch result {
            case .success(_):
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
                
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                
            case .failure(let error):
                self.presentSimpleAlert(title: "로그인 실패", message: error.errorDescription)
            }
        }
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

