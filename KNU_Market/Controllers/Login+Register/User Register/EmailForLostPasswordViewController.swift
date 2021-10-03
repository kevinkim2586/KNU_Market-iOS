import UIKit
import TextFieldEffects

class EmailForLostPasswordViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let emailTextField  = KMTextField(placeHolderText: "이메일 주소 입력")
    private let errorLabel      = KMErrorLabel()
    private let bottomButton    = KMBottomButton(buttonTitle: "크누마켓 시작하기")

    private let padding: CGFloat = 20
    
    typealias RegisterError = ValidationError.OnRegister
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
}

//MARK: - Registration Method

extension EmailForLostPasswordViewController {

    func registerUser() {
        showProgressBar()

        let model = RegisterRequestDTO(
            id: UserRegisterValues.shared.userId,
            password: UserRegisterValues.shared.password,
            nickname: UserRegisterValues.shared.nickname,
            fcmToken: UserRegisterValues.shared.fcmToken,
            emailForPasswordLoss: UserRegisterValues.shared.emailForPasswordLoss
        )
    
        UserManager.shared.register(with: model) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success:
                DispatchQueue.main.async { self.showCongratulateRegisterVC() }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func showCongratulateRegisterVC() {
        guard let vc = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.congratulateUserVC
        ) as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

//MARK: - Target Methods

extension EmailForLostPasswordViewController {
    
    @objc func pressedBottomButton(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        if !checkIfValidEmail() { return }
        checkEmailDuplication(email: emailTextField.text!)
        
    }
}

//MARK: - User Input Validation

extension EmailForLostPasswordViewController {
    
    func checkIfValidEmail() -> Bool {
        guard let email = emailTextField.text else { return false }
        if !email.isValidEmail {
            errorLabel.showErrorMessage(message: RegisterError.inValidEmailFormat.rawValue)
            return false
        }
        return true
    }
    
    func checkEmailDuplication(email: String) {
        
        UserManager.shared.checkDuplication(emailForPasswordLoss: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: RegisterError.existingEmail.rawValue)
                } else {
                    UserRegisterValues.shared.emailForPasswordLoss = email
                    self.registerUser()
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}


//MARK: - UI Configuration & Initialization

extension EmailForLostPasswordViewController {
    
    func initialize() {
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }

    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "비밀번호 분실 시 임시 비밀번호를 받을\n이메일 주소를 입력해주세요!"
        titleLabel.numberOfLines = 2
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "이메일 주소"
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    
    func initializeTextField() {
        view.addSubview(emailTextField)
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeBottomButton() {
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
        emailTextField.inputAccessoryView = bottomButton
    }
}
