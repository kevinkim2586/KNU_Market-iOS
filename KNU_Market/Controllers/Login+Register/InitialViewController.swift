import UIKit
import PanModal

class InitialViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    
    private lazy var idGuideString = "2021년 10월 6일 이전에 가입한 회원의 아이디는 웹메일(@knu.ac.kr) 형식입니다."
    
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
        performSegue(withIdentifier: Constants.SegueID.goToRegister, sender: self)
    }
    
    @IBAction func pressedFindPwButton(_ sender: UIButton) {

        
    }
    
    
    @IBAction func pressedFindIdButton(_ sender: UIButton) {

        let storyboard = UIStoryboard(
            name: StoryboardName.FindUserInfo,
            bundle: nil
        )
        guard let findIdVC = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.chooseVerificationOptionVC
        ) as? ChooseVerificationOptionViewController else { return }
        
        findIdVC.delegate = self
        present(findIdVC, animated: true)
    }
    
    @IBAction func pressedInfoButton(_ sender: UIButton) {
        let attributedMessageString: NSAttributedString = idGuideString.attributedStringWithColor(
            ["2021년 10월 6일 이전에 가입한 회원"],
            color: UIColor(named: Constants.Color.appColor) ?? .systemPink,
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
        performSegue(withIdentifier: Constants.SegueID.goToRegister, sender: self)
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
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
    
    func initializeRegisterButton() {
        registerButton.setTitle("회원가입", for: .normal)
        registerButton.setTitleColor(
            UIColor(named: Constants.Color.appColor),
            for: .normal
        )
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        registerButton.addBounceAnimationWithNoFeedback()
    }
}
