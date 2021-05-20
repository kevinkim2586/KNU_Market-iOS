import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    
    }
    
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        guard let id = idTextField.text, let password = passwordTextField.text else { return }
        guard id.count > 0, password.count > 0 else { return }
        
        showProgressBar()
    
        UserManager.shared.login(id: id, password: password) { result in
            
            switch result {
            case .success(_):
                self.changeRootViewController()
            case .failure(let error):
                self.presentSimpleAlert(title: "로그인 실패", message: error.errorDescription)
            }
            dismissProgressBar()
        }
    }
    
    func changeRootViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
        }
    }
}

//MARK: - UI Configuration

extension LoginViewController {
    
    func initialize() {
        
        initializeDelegates()
        initializeTextFields()
        initializeLoginButton()
    }
    
    func initializeDelegates() {
        
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func initializeTextFields() {
        
        idTextField.layer.cornerRadius = 1
        idTextField.layer.borderWidth = 1
        idTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
        
        passwordTextField.layer.cornerRadius = 1
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
        
        var idImage = UIImage(named: "idImage")
        idImage = idImage?.scalePreservingAspectRatio(targetSize: CGSize(width: 25,
                                                                         height: 25))
        var pwImage = UIImage(named: "pwImage")
        pwImage = pwImage?.scalePreservingAspectRatio(targetSize: CGSize(width: 25,
                                                                         height: 25))
        
        let idLeftImageView = UIImageView(frame: CGRect(x: 10,
                                                        y: 10,
                                                        width: 20,
                                                        height: 20))
        idLeftImageView.image = idImage
        idTextField.leftView = idLeftImageView
        idTextField.leftViewMode = .always
        
        let pwLeftImageView = UIImageView(frame: CGRect(x: 10,
                                                        y: 10,
                                                        width: 20,
                                                        height: 20))
        pwLeftImageView.image = pwImage
        passwordTextField.leftView = pwLeftImageView
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        
        
        //MARK: - TEST DATA
        idTextField.text = "kevinkim2586@gmail.com"
        passwordTextField.text = "123456789"
        
        
        
        
        
    }
    
    func initializeLoginButton() {
        
        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
}

