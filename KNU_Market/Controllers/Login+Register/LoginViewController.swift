import UIKit
import PanModal

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
 
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        guard let id = idTextField.text, let password = passwordTextField.text else { return }
        guard id.count > 0, password.count > 0 else { return }
        
        showProgressBar()
    
        UserManager.shared.login(email: id, password: password) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                print("LoginViewController - login success")
                self.goToHomeScreen()
                
            case .failure(let error):
                self.presentSimpleAlert(title: "로그인 실패", message: error.errorDescription)
            }
            dismissProgressBar()
        }
    }
    
    // 아래 구현하기
    @IBAction func pressedFindPasswordButton(_ sender: UIButton) {
        
        guard let findPasswordVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.findPasswordVC) as? FindPasswordViewController else { return }
        
        findPasswordVC.delegate = self
        
        presentPanModal(findPasswordVC)
    }
 
}

extension LoginViewController: FindPasswordDelegate {
    
    func didSendFindPasswordEmail() {
        self.showSimpleBottomAlert(with: "발급받은 임시 비밀번호로 로그인해 주세요. 🎉")
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

//MARK: - UI Configuration & Initialization

extension LoginViewController {
    
    func initialize() {
        
        initializeDelegates()
        addDismissButtonToRightNavBar()
        initializeTextFields()
        initializeLoginButton()
    }
    
    func initializeDelegates() {
        
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func initializeTextFields() {
        
        idTextField.layer.cornerRadius = idTextField.frame.height / 2
        idTextField.layer.borderWidth = 1
        idTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
        
        passwordTextField.layer.cornerRadius = passwordTextField.frame.height / 2
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
        
    }
    
    func initializeLoginButton() {
        
        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
}

