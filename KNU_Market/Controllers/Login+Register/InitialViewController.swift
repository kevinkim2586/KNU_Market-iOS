import UIKit
import PanModal

class InitialViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    private lazy var idGuideString = "2021년 10월 6일 이전에 가입한 회원의 아이디는 웹메일(@knu.ac.kr) 형식입니다."
    
    private lazy var findUserInfoStoryboard = UIStoryboard(
        name: StoryboardName.FindUserInfo,
        bundle: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func presentVC(_ vc: UIViewController) {
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    

}

//MARK: - IBActions

extension InitialViewController {
    
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        guard let id = idTextField.text, let password = pwTextField.text else { return }
        guard id.count > 0, password.count > 0 else { return }
        
        showProgressBar()
    
        UserManager.shared.login(email: id, password: password) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.goToHomeScreen()
            case .failure(let error):
                self.presentKMAlertOnMainThread(
                    title: "로그인 실패",
                    message: error.errorDescription,
                    buttonTitle: "확인"
                )
            }
            dismissProgressBar()
        }
    }
    
    @IBAction func pressedRegisterButton(_ sender: UIButton) {
        performSegue(withIdentifier: K.SegueID.goToRegister, sender: self)
    }
    
    @IBAction func pressedFindIdButton(_ sender: UIButton) {
        guard let findIdVC = findUserInfoStoryboard.instantiateViewController(
            identifier: K.StoryboardID.chooseVerificationOptionVC
        ) as? ChooseVerificationOptionViewController else { return }
        
        findIdVC.delegate = self
        presentVC(findIdVC)
    }
    
    @IBAction func pressedFindPwButton(_ sender: UIButton) {
        guard let findPwVC = findUserInfoStoryboard.instantiateViewController(
            identifier: K.StoryboardID.findPasswordVC
        ) as? FindPasswordViewController else { return }
        presentVC(findPwVC)
    }
    
    @IBAction func pressedInfoButton(_ sender: UIButton) {
        let attributedMessageString: NSAttributedString = idGuideString.attributedStringWithColor(
            ["2021년 10월 6일 이전에 가입한 회원"],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
        
        presentKMAlertOnMainThread(
            title: "안내",
            message: "",
            buttonTitle: "확인",
            attributedMessageString: attributedMessageString
        )
    }
}

//MARK: - ChooseVerificationOptionDelegate

extension InitialViewController: ChooseVerificationOptionDelegate {
    
    func didSelectToRegister() {
        performSegue(withIdentifier: K.SegueID.goToRegister, sender: self)
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
        
        [idTextField, pwTextField].forEach { textfield in
            guard let textfield = textfield else { return}
            textfield.borderStyle = .none
            textfield.backgroundColor = .systemGray6
            textfield.layer.cornerRadius = textfield.frame.height / 2
            textfield.textAlignment = .center
            textfield.adjustsFontSizeToFitWidth = true
            textfield.minimumFontSize = 12
            textfield.layer.masksToBounds = true
            textfield.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        }
        pwTextField.isSecureTextEntry = true

        idTextField.placeholder = "아이디 입력"
        pwTextField.placeholder = "비밀번호 입력"
    }
    
    func initializeLoginButton() {
        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        loginButton.backgroundColor = UIColor(named: K.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
    
    func initializeRegisterButton() {
        registerButton.setTitle("회원가입", for: .normal)
        registerButton.setTitleColor(
            UIColor(named: K.Color.appColor),
            for: .normal
        )
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        registerButton.addBounceAnimationWithNoFeedback()
    }
}
