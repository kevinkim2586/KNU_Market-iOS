import UIKit
import ProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!
    
    private var viewModel: LoginViewModel = LoginViewModel()

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
        
        
    }
    
    @objc func dismissVC() {
        
        self.dismiss(animated: true)
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
        initializeNavigationBar()
        initializeTextFields()
        initializeLoginButton()
    }
    
    func initializeDelegates() {
        
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func initializeNavigationBar() {
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 150
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight,
                                                          width: view.bounds.size.width, height: 50))
        navigationBar.tintColor = .lightGray
        navigationBar.setBackgroundImage(UIImage(),
                                         for: .default)
        navigationBar.shadowImage = UIImage()
        self.view.addSubview(navigationBar)
        
        let navItem = UINavigationItem(title: "")
        let navBarButton = UIBarButtonItem(barButtonSystemItem: .stop,
                                           target: self,
                                           action: #selector(dismissVC))
        navBarButton.tintColor = .black
        navItem.leftBarButtonItem = navBarButton
        navigationBar.items = [navItem]
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
        
        
        //MARK: - TEST DATA
        
        idTextField.text = "kimyoungchae@knu.ac.kr"
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

