import UIKit
import TextFieldEffects

class EmailForLostPasswordViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let emailTextField  = KMTextField(placeHolderText: "이메일 주소 입력")
    private let errorLabel      = KMErrorLabel()
    private let bottomButton    = KMBottomButton(buttonTitle: "크누마켓 시작하기")

    private let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardSize.height).isActive = true
            bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
            bottomButton.updateTitleEdgeInsetsForKeyboardAppeared()
            view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        bottomButton.frame.origin.y = view.bounds.height - bottomButton.heightConstantForKeyboardHidden
    }
    
    @objc func pressedBottomButton(_ sender: UIButton) {
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
            identifier: K.StoryboardID.congratulateUserVC
        ) as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

//MARK: - User Input Validation

extension EmailForLostPasswordViewController {
    
    func checkIfValidEmail() -> Bool {
        guard let email = emailTextField.text else { return false }
        
        if !email.isValidEmail {
            errorLabel.showErrorMessage(message: "유효한 이메일인지 확인해주세요.")
            return false
        }
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}


//MARK: - UI Configuration & Initialization

extension EmailForLostPasswordViewController {
    
    func initialize() {
        createObserverForKeyboardStateChange()
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
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
        view.addSubview(bottomButton)
        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
        
        NSLayoutConstraint.activate([
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardHidden)
        ])
    }
    

}
