import UIKit

class ChangeEmailForPasswordLossViewController: UIViewController {
    
    private let detailLabel         = KMDetailLabel(fontSize: 15, numberOfTotalLines: 5)
    private let emailTextField      = KMTextField(placeHolderText: "변경하실 이메일 입력")
    private let errorLabel          = KMErrorLabel()
    private let changeEmailButton   = KMBottomButton(buttonTitle: "변경하기")
    
    private let padding: CGFloat = 20
    
    typealias InputError = ValidationError.OnChangeUserInfo

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
}

//MARK: - Target Methods

extension ChangeEmailForPasswordLossViewController {
    
    @objc func pressedChangeEmailButton() {
        emailTextField.resignFirstResponder()
        if !checkIfValidEmail() { return }
        UserManager.shared.updateUserInfo(
            type: .email,
            infoString: emailTextField.text!
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showSimpleBottomAlert(with: "이메일 변경에 성공하셨어요.🎉")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.errorLabel.showErrorMessage(message: error.errorDescription)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}

//MARK: - User Input Validation

extension ChangeEmailForPasswordLossViewController {
    
    func checkIfValidEmail() -> Bool {
        guard let email = emailTextField.text else { return false }
        if !email.isValidEmail {
            errorLabel.showErrorMessage(message: InputError.invalidEmailFormat.rawValue)
            return false
        }
        return true
    }
}


//MARK: - UI Configuration & Initialization

extension ChangeEmailForPasswordLossViewController {
    
    func initialize() {
        title = "이메일 변경"
        view.backgroundColor = .white
        initializeDetailLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeChangeEmailButton()
    }
    
    func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.text = "새로운 이메일 주소를 입력해주세요.\n비밀번호 분실 시, 해당 이메일 주소로 임시 비밀번호가\n 전송되니, 이메일 변경은 신중히 부탁드립니다."
        detailLabel.textAlignment = .center
        detailLabel.textColor = .darkGray
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
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
            emailTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    func initializeChangeEmailButton() {
        changeEmailButton.heightAnchor.constraint(equalToConstant: changeEmailButton.heightConstantForKeyboardAppeared).isActive = true
        changeEmailButton.addTarget(
            self,
            action: #selector(pressedChangeEmailButton),
            for: .touchUpInside
        )
        emailTextField.inputAccessoryView = changeEmailButton
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct ChangeEmailVC: PreviewProvider {
    
    static var previews: some View {
        ChangeEmailForPasswordLossViewController().toPreview()
    }
}
#endif
