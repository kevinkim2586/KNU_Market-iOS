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

