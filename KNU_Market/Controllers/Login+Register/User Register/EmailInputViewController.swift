import UIKit
import TextFieldEffects

class EmailInputViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    @IBOutlet weak var idInfoLabel: UILabel!
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var emailTextField: HoshiTextField!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    private var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            nextButtonBottomAnchor.constant = keyboardSize.height
            nextButtonHeight.constant = 60
            nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
    }
    
    @IBAction func pressedSendEmailButton(_ sender: UIButton) {
        if !checkIfValidEmail() { return }
        presentAlertWithCancelAction(title: emailTextField.text!,
                                     message: "위 이메일이 맞나요? 마지막으로 한 번 더 확인해 주세요.") { selectedOk in
            
            if selectedOk {
                self.emailTextField.resignFirstResponder()
        
                guard let email = self.emailTextField.text?.trimmingCharacters(in: .whitespaces) else {
                    self.showSimpleBottomAlert(with: "올바른 이메일 형식인지 다시 한 번 확인해주세요.")
                    return
                }
                self.email = email
                self.sendVerificationEmail(to: email)
            }
        }
    }
    
    func sendVerificationEmail(to email: String) {
        showProgressBar()
        UserManager.shared.sendVerificationEmail(email: email) { [weak self] result in
            dismissProgressBar()
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.goToCheckEmailVC()
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func goToCheckEmailVC() {
        guard let vc = storyboard?.instantiateViewController(
            identifier: Constants.StoryboardID.checkEmailVC
        ) as? CheckEmailViewController else { return }
        
        guard let email = email else { return }
        
        vc.email = email
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func registerUser() {
//
//        showProgressBar()
//
//        let model = RegisterRequestDTO(id: UserRegisterValues.shared.email,
//                                       password: UserRegisterValues.shared.password,
//                                       nickname: UserRegisterValues.shared.nickname,
//                                       image: UserRegisterValues.shared.profileImage,
//                                       fcmToken: UserRegisterValues.shared.fcmToken)
//
//        UserManager.shared.register(with: model) { [weak self] result in
//
//            guard let self = self else { return }
//
//            dismissProgressBar()
//
//            switch result {
//            case .success:
//                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: Constants.SegueID.goToCheckEmailVC, sender: self)
//                }
//            case .failure(let error):
//                self.showSimpleBottomAlert(with: error.errorDescription)
//
//            }
//        }
//    }
}

//MARK: - UI Configuration & Initialization

extension EmailInputViewController {
    
    func initialize() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification ,
            object: nil
        )
        
        title = "웹메일 인증"
        
        initializeLabels()
        initializeTextFields()
    }
    
    func initializeTextFields() {
        
        emailTextField.addTarget(self,
                                 action: #selector(textFieldDidChange(_:)),
                                 for: .editingChanged)
    }
    
    func initializeLabels() {
        
        errorLabel.isHidden = true
        
        titleLabel.text = "웹메일(@knu.ac.kr)을 입력해주세요."
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "웹메일(@knu.ac.kr)을 입력"
        )
    
        
        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 반드시 스팸 메일함을\n확인해주세요."
        idInfoLabel.text = "웹메일 ID는 yes 포털 아이디와 동일합니다."
        

        labels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            label.textColor = .darkGray
        }
        
        checkSpamMailLabel.changeTextAttributeColor(
            fullText: checkSpamMailLabel.text!,
            changeText: "반드시 스팸 메일함을\n확인"
        )
        idInfoLabel.changeTextAttributeColor(
            fullText: idInfoLabel.text!,
            changeText: "yes 포털 아이디와 동일"
        )
    }
}

//MARK: - User Input Validation

extension EmailInputViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        dismissErrorMessage()
    }
    
    func checkIfValidEmail() -> Bool {
        
        guard let email = emailTextField.text else {
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요.🤔")
            return false
        }
        
        guard email.contains("@knu.ac.kr") else {
            showErrorMessage(message: "경북대학교 이메일이 맞는지 확인해 주세요.🧐")
            return false
        }
        
        guard email.count > 10 else {
            showErrorMessage(message: "유효한 이메일인지 확인해 주세요. 👀")
            return false
        }
        return true
    }
    
    func dismissErrorMessage() {
        errorLabel.isHidden = true
    }
    
    func showErrorMessage(message: String) {
        
        errorLabel.isHidden = false
        errorLabel.text = message
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        errorLabel.textColor = UIColor(named: Constants.Color.appColor)
        
    }
}
