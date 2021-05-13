import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    private let spinner = JGProgressHUD(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    
    }
    
    
    
    


    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        spinner.show(in: view)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
        spinner.dismiss()

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

