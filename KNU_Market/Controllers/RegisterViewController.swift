import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailVerificationButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var checkAlreadyInUseButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    
    
    @IBAction func pressedImageUploadButton(_ sender: UIButton) {
        
        
    }
    
    @IBAction func pressedSendEmailVerificationButton(_ sender: UIButton) {
        
    }
    
    @IBAction func pressedCheckAlreadyInUseButton(_ sender: UIButton) {
        
    }
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        
    }
    
    
    
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    
}


//MARK: - UI Configuration

extension RegisterViewController {
    
    func initialize() {
        
        initializeDelegates()
        initializeNextButton()
        
    }
    
    func initializeDelegates() {
        
        emailTextField.delegate = self
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }
    
    func initializeNextButton() {
        
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.backgroundColor = UIColor(named: Constants.Colors.appDefaultColor)
        nextButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
    }
    
}
