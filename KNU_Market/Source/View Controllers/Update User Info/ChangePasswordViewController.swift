import UIKit
import  SnackBar_swift

class ChangePasswordViewController: UIViewController {
    
    private let titleLabel              = KMTitleLabel(textColor: .darkGray)
    private let passwordTextField       = KMTextField(placeHolderText: "비밀번호")
    private let checkPasswordTextField  = KMTextField(placeHolderText: "비밀번호 확인")
    private let errorLabel              = KMErrorLabel()
    private let changePasswordButton    = KMBottomButton(buttonTitle: "변경하기")
    
    private let padding: CGFloat = 20

    typealias InputError = ValidationError.OnRegister
    
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

extension ChangePasswordViewController {
    
    @objc func pressedChangePasswordButton() {
        view.endEditing(true)
        if !validPassword() || !checkPasswordLengthIsValid() || !checkIfPasswordFieldsAreIdentical() { return }
        
        let newPassword = passwordTextField.text!
    
        showProgressBar()
        
        UserManager.shared.updateUserInfo(
            type: .password,
            infoString: newPassword
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showSimpleBottomAlert(with: "비밀번호 변경에 성공하셨어요.🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                self.errorLabel.showErrorMessage(message: "비밀번호 변경 실패. 잠시 후 다시 시도해주세요. 🥲")
            }
            dismissProgressBar()
        }
        

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}

//MARK: - User Input Validation

extension ChangePasswordViewController {
    
    func validPassword() -> Bool {
        
        guard let userPW = passwordTextField.text else {
            errorLabel.showErrorMessage(message: InputError.empty.rawValue)
            return false
        }
        
        let passwordREGEX = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordTesting = NSPredicate(format: "SELF MATCHES %@", passwordREGEX)
        
        if passwordTesting.evaluate(with: userPW) == true {
            return true
        } else {
            errorLabel.showErrorMessage(message: InputError.incorrectPasswordFormat.rawValue)
            return false
        }
    }
    
    func checkPasswordLengthIsValid() -> Bool {
        
        guard let password = passwordTextField.text, let _ = checkPasswordTextField.text else {
            errorLabel.showErrorMessage(message: InputError.empty.rawValue)
            return false
        }
        
        if password.count >= 8 && password.count <= 20 { return true }
        else {
            errorLabel.showErrorMessage(message: InputError.incorrectPasswordFormat.rawValue)
            return false
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            errorLabel.showErrorMessage(message: InputError.passwordDoesNotMatch.rawValue)
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }

}

//MARK: - UI Configuration

extension ChangePasswordViewController {
    
    private func initialize() {
        title = "비밀번호 변경"
        view.backgroundColor = .white
        initializeTitleLabel()
        initializeTextFields()
        initializeErrorLabel()
        initializeChangePasswordButton()
    }
    
    private func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "새 비밀번호를 입력해주세요."
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    private func initializeTextFields() {
        view.addSubview(passwordTextField)
        view.addSubview(checkPasswordTextField)
        
        passwordTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        checkPasswordTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        passwordTextField.isSecureTextEntry = true
        checkPasswordTextField.isSecureTextEntry = true
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            
            checkPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            checkPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            checkPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            checkPasswordTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: checkPasswordTextField.bottomAnchor, constant: 25),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
        
    }
    
    private func initializeChangePasswordButton() {
        changePasswordButton.heightAnchor.constraint(equalToConstant: changePasswordButton.heightConstantForKeyboardAppeared).isActive = true
        changePasswordButton.addTarget(
            self,
            action: #selector(pressedChangePasswordButton),
            for: .touchUpInside
        )
        passwordTextField.inputAccessoryView = changePasswordButton
        checkPasswordTextField.inputAccessoryView = changePasswordButton
    }
}
