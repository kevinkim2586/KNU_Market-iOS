import UIKit

class ChangeIdViewController: UIViewController {
    
    private let detailLabel         = KMDetailLabel(fontSize: 15, numberOfTotalLines: 1)
    private let idTextField         = KMTextField(placeHolderText: "새 아이디 입력")
    private let errorLabel          = KMErrorLabel()
    private let changeIdButton      = KMBottomButton(buttonTitle: "변경하기")
    
    private let padding: CGFloat = 20
    
    typealias InputError = ValidationError.OnChangeUserInfo

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        idTextField.becomeFirstResponder()
    }
}

//MARK: - Target Methods

extension ChangeIdViewController {
    
    @objc func pressedChangeIdButton() {
        idTextField.resignFirstResponder()
        if !checkIfValidId() { return  }
        checkIDDuplication()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    func updateUserId(with id: String) {
        UserManager.shared.updateUserInfo(
            type: .id,
            infoString: id
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showSimpleBottomAlert(with: "아이디 변경에 성공하셨어요.🎉")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.errorLabel.showErrorMessage(message: error.errorDescription)
            }
        }
    }
}

//MARK: - User Input Validation

extension ChangeIdViewController {
    
    func checkIfValidId() -> Bool {
        guard let id = idTextField.text else { return false }
        
        if id.count < 4 || id.count > 30 {
            errorLabel.showErrorMessage(message: InputError.incorrectIdLength.rawValue)
            return false
        }
        
        if !id.isValidEmail, !id.isValidId {
            errorLabel.showErrorMessage(message: InputError.incorrectIdFormat.rawValue)
            return false
        }
        return true
    }
    
    func checkIDDuplication() {
        
        let id = idTextField.text!.trimmingCharacters(in: .whitespaces)
        
        UserManager.shared.checkDuplication(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: InputError.existingId.rawValue)
                } else {
                    self.updateUserId(with: id)
                }
            case .failure(let error):
                self.errorLabel.showErrorMessage(message: error.errorDescription)
            }
        }
    }
    
}

//MARK: - UI Configuration & Initialization

extension ChangeIdViewController {
    
    func initialize() {
        title = "아이디 변경"
        view.backgroundColor = .white
        initializeDetailLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeChangeEmailButton()
    }
    
    func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.text = "새로운 아이디를 입력해주세요."
        detailLabel.textAlignment = .center
        detailLabel.textColor = .darkGray
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    func initializeTextField() {
        view.addSubview(idTextField)
        idTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            idTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 30),
            idTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            idTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            idTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: idTextField.bottomAnchor, constant: 30),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
        ])
    }
    
    func initializeChangeEmailButton() {
        changeIdButton.heightAnchor.constraint(equalToConstant: changeIdButton.heightConstantForKeyboardAppeared).isActive = true
        changeIdButton.addTarget(
            self,
            action: #selector(pressedChangeIdButton),
            for: .touchUpInside
        )
        idTextField.inputAccessoryView = changeIdButton
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct ChangeIdVC: PreviewProvider {
    
    static var previews: some View {
        ChangeIdViewController().toPreview()
    }
}
#endif
