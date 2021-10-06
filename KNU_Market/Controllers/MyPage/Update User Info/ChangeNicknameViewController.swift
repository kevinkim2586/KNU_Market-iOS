import UIKit

class ChangeNicknameViewController: UIViewController {
    
    private let titleLabel              = KMTitleLabel(textColor: .darkGray)
    private let nicknameTextField       = KMTextField(placeHolderText: "닉네임 입력")
    private let errorLabel              = KMErrorLabel()
    private let changeNicknameButton    = KMBottomButton(buttonTitle: "변경하기")

    private let padding: CGFloat = 20
    
    typealias InputError = ValidationError.OnChangingUserInfo
    
    private var nickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
}

//MARK: - Target Methods

extension ChangeNicknameViewController {
    
    @objc private func pressedChangeNicknameButton() {
        nicknameTextField.resignFirstResponder()
        if !validateUserInput() { return }
        checkNicknameDuplication()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    private func checkNicknameDuplication() {
        
        UserManager.shared.checkDuplication(nickname: nickname!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    DispatchQueue.main.async {
                        self.errorLabel.showErrorMessage(message: InputError.existingNickname.rawValue)
                    }
                } else {
                    self.updateUserNickname(with: self.nickname!)
                }
            case .failure(_):
                self.showSimpleBottomAlert(with: NetworkError.E000.errorDescription)
            }
        }
    }
    
    private func updateUserNickname(with nickname: String) {
        showProgressBar()
        UserManager.shared.updateUserInfo(
            type: .nickname,
            infoString: nickname
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showSimpleBottomAlert(with: "닉네임이 변경되었어요.🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(_):
                self.showSimpleBottomAlert(with: "닉네임 변경 실패. 잠시 후 다시 시도해주세요 🥲")
            }
        }
        dismissProgressBar()
    }
}

//MARK: - User Input Validation

extension ChangeNicknameViewController {
    
    func validateUserInput() -> Bool {
        
        guard let nickname = nicknameTextField.text else {
            return false
        }
        guard !nickname.isEmpty else {
            errorLabel.showErrorMessage(message: InputError.empty.rawValue)
            return false
        }
        guard nickname.count >= 2, nickname.count <= 15 else {
            errorLabel.showErrorMessage(message: InputError.incorrectNicknameLength.rawValue)
            return false
        }
        self.nickname = nickname
        return true
    }
}

//MARK: - UI Configuration

extension ChangeNicknameViewController {
    
    private func initialize() {
        view.backgroundColor = .white
        title = "닉네임 변경"
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeChangeNicknameButton()
    }
    
    private func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "새로운 닉네임을 입력해주세요."
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    private func initializeTextField() {
        view.addSubview(nicknameTextField)
        nicknameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: padding),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    private func initializeChangeNicknameButton() {
        changeNicknameButton.heightAnchor.constraint(equalToConstant: changeNicknameButton.heightConstantForKeyboardAppeared).isActive = true
        changeNicknameButton.addTarget(
            self,
            action: #selector(pressedChangeNicknameButton),
            for: .touchUpInside
        )
        nicknameTextField.inputAccessoryView = changeNicknameButton
    }
    

}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct ChangeNicknameVC: PreviewProvider {
    
    static var previews: some View {
        ChangeNicknameViewController().toPreview()
    }
}
#endif
