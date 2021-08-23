import UIKit
import TextFieldEffects

class EmailInputViewController: UIViewController {
    
    @IBOutlet weak var firstLineLabel: UILabel!
    
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var fourthLineLabel: UILabel!
    @IBOutlet var detailLabels: [UILabel]!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var emailTextField: HoshiTextField!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()

        
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            nextButtonBottomAnchor.constant = keyboardSize.height
            nextButtonHeight.constant = 60
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        if !checkIfValidEmail() { return }
        
        emailTextField.resignFirstResponder()
        
        UserRegisterValues.shared.email = emailTextField.text!
        
        registerUser()
    }
    
    func registerUser() {
        
        showProgressBar()
        
        let model = RegisterRequestDTO(id: UserRegisterValues.shared.email,
                                       password: UserRegisterValues.shared.password,
                                       nickname: UserRegisterValues.shared.nickname,
                                       image: UserRegisterValues.shared.profileImage,
                                       fcmToken: UserRegisterValues.shared.fcmToken)
        
        UserManager.shared.register(with: model) { [weak self] result in
            
            guard let self = self else { return }
            
            dismissProgressBar()
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: Constants.SegueID.goToCheckEmailVC, sender: self)
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
                
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension EmailInputViewController {
    
    func initialize() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification , object: nil)
        
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
        
        firstLineLabel.text = "마지막으로 학교 이메일 인증을 해주세요!"
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "학교 이메일 인증")
        
        secondLineLabel.text = "크누마켓은 경북대학교 학생들을 위한 공동구매 앱입니다."
        secondLineLabel.changeTextAttributeColor(fullText: secondLineLabel.text!, changeText: "크누마켓")
        thirdLineLabel.text = "앱의 모든 기능을 사용하기 위해서는 반드시 이메일 인증을"
        fourthLineLabel.text = "하셔야 합니다."
        
        detailLabels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .lightGray
        }
        
        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 스팸 메일함을 확인해주세요."
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
