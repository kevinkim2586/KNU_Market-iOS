import UIKit

class UnregisterUser_InputPasswordViewController: UIViewController {
    
    private let titleLabel          = KMTitleLabel(textColor: .darkGray)
    private let passwordTextField   = KMTextField(placeHolderText: "비밀번호")
    private let errorLabel          = KMErrorLabel()
    private let bottomButton        = KMBottomButton(buttonTitle: "다음")
    
    private let padding: CGFloat = 20
    
    private let titleLabelText          = "회원탈퇴라니요..\n한 번만 더 생각해 주세요.😥"
    private let errorLabelText          = "회원 탈퇴를 위해 비밀번호를 입력해 주세요."
    private let incorrectPasswordText   = "비밀번호가 일치하지 않습니다. 다시 시도해 주세요."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
}

//MARK: - Target Methods

extension UnregisterUser_InputPasswordViewController {
    
    @objc func pressedBottomButton() {
        guard let password = passwordTextField.text else {
            errorLabel.showErrorMessage(message: incorrectPasswordText)
            return
        }
        
        UserManager.shared.login(
            id: User.shared.userID,
            password: password
        ) { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(UnregisterUser_InputSuggestionViewController(userManager: UserManager()), animated: true)
                }
            case .failure(_):
                self.errorLabel.showErrorMessage(message: self.incorrectPasswordText)
            }
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.text = errorLabelText
        errorLabel.textColor = .lightGray
    }
}

//MARK: - UI Configuration & Initialization

extension UnregisterUser_InputPasswordViewController {
    
    private func initialize() {
        view.backgroundColor = .white
        setBackBarButtonItemTitle(to: "")
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    private func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.text = titleLabelText
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    private func initializeTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.text = errorLabelText
        errorLabel.numberOfLines = 2
        errorLabel.isHidden = false
        errorLabel.textColor = .lightGray
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 25),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
            
        ])
    }
    
    private func initializeBottomButton() {
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        passwordTextField.inputAccessoryView = bottomButton

        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
    }
    
}
