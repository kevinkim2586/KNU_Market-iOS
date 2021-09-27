import UIKit
import TextFieldEffects

class EmailForLostPasswordViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            nextButtonBottomAnchor.constant = keyboardSize.height
            nextButtonHeight.constant = 60
            nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
        nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        if !checkIfValidEmail() { return }
        registerUser()
    }

    
    func registerUser() {
        
        showProgressBar()
        #warning("회원 가입 수정 필요")
        let model = RegisterRequestDTO(
            id: UserRegisterValues.shared.userId,
            password: UserRegisterValues.shared.password,
            nickname: UserRegisterValues.shared.nickname,
            fcmToken: UserRegisterValues.shared.fcmToken
        )
        
        UserManager.shared.register(with: model) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showCongratulateRegisterVC()
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    
    func showCongratulateRegisterVC() {
        guard let vc = storyboard?.instantiateViewController(
            identifier: Constants.StoryboardID.congratulateUserVC
        ) as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

//MARK: - User Input Validation

extension EmailForLostPasswordViewController {
    
    func checkIfValidEmail() -> Bool {
        guard let email = emailTextField.text else { return }
        
        if !email.isValidEmail {
            showErrorMessage(message: "유효한 이메일인지 확인해주세요.")
            return false
        }
        
        return true
    }
    
    func showErrorMessage(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        errorLabel.textColor = UIColor(named: Constants.Color.appColor)
    }
    
    func dismissErrorMessage() {
        errorLabel.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        dismissErrorMessage()
    }
}


//MARK: - UI Configuration & Initialization

extension EmailForLostPasswordViewController {
    
    func initialize() {
        createObserverForKeyboardStateChange()
        initializeTextField()
        initializeLabels()
    }
    
    func createObserverForKeyboardStateChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name:UIResponder.keyboardWillHideNotification ,
            object: nil
        )
    }
    
    func initializeTextField() {
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    func initializeLabels() {
        errorLabel.isHidden = true
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.text = "비밀번호 분실 시 임시 비밀번호를 받을\n이메일 주소를 입력해주세요! "
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "이메일 주소"
        )
    }
}
