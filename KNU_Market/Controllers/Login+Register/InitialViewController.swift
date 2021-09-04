import UIKit
import PanModal

class InitialViewController: UIViewController {


    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    //MARK: - IBActions
    
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        guard let id = idTextField.text, let password = pwTextField.text else { return }
        guard id.count > 0, password.count > 0 else { return }
        
        showProgressBar()
    
        UserManager.shared.login(email: id, password: password) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                
                print("LoginViewController - login success")
                self.goToHomeScreen()
                
            case .failure(let error):
                self.presentKMAlertOnMainThread(title: "로그인 실패", message: error.errorDescription, buttonTitle: "확인")
            }
            dismissProgressBar()
        }
        
        
    }
    
    @IBAction func pressedRegisterButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.SegueID.goToRegister, sender: self)
    }
    
    @IBAction func pressedFindPWButton(_ sender: UIButton) {
        
        guard let findPasswordVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.findPasswordVC) as? FindPasswordViewController else { return }
        
        findPasswordVC.delegate = self
        presentPanModal(findPasswordVC)
    }
}

extension InitialViewController: FindPasswordDelegate {
    
    func didSendFindPasswordEmail() {
        self.showSimpleBottomAlert(with: "발급받은 임시 비밀번호로 로그인해 주세요. 🎉")
    }
}

//MARK: - UI Configuration & Initialization
extension InitialViewController {
   
    func initialize() {
        
        initializeTextFields()
        initializeLoginButton()
        initializeRegisterButton()
    }
    
    func initializeTextFields() {
        
        idTextField.borderStyle = .none
        idTextField.backgroundColor = .systemGray6
        idTextField.layer.cornerRadius = idTextField.frame.height / 2
        idTextField.textAlignment = .center
        idTextField.adjustsFontSizeToFitWidth = true
        idTextField.minimumFontSize = 12
        idTextField.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        
        idTextField.placeholder = "학교 이메일 입력 (@knu.ac.kr)"
        
        pwTextField.borderStyle = .none
        pwTextField.backgroundColor = .systemGray6
        pwTextField.layer.cornerRadius = idTextField.frame.height / 2
        pwTextField.textAlignment = .center
        pwTextField.adjustsFontSizeToFitWidth = true
        pwTextField.minimumFontSize = 12
        pwTextField.isSecureTextEntry = true
        pwTextField.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        pwTextField.placeholder = "비밀번호 입력"
        
    }
    
    func initializeLoginButton() {

        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
    
    func initializeRegisterButton() {
        
        registerButton.setTitle("회원가입", for: .normal)
        registerButton.setTitleColor(UIColor(named: Constants.Color.appColor), for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        registerButton.addBounceAnimationWithNoFeedback()
    }
}
