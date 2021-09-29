import UIKit
import TextFieldEffects

class IDInputViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let userIdTextField = KMTextField(placeHolderText: "아이디 입력")
    private let errorLabel      = KMErrorLabel()
    private let bottomButton    = KMBottomButton(buttonTitle: "다음")
    
    private let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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
    
    @objc func pressedBottomButton() {
        userIdTextField.resignFirstResponder()
        if !checkIfValidId() { return }
        checkIDDuplication()
    }
}

//MARK: - User Input Validation

extension IDInputViewController {
    
    func checkIfValidId() -> Bool {
        guard let id = userIdTextField.text else { return false}
        
        if id.hasSpecialCharacters {
            errorLabel.showErrorMessage(message: "아이디에 특수 문자와 한글을 포함할 수 없어요.")
            return false
        }
        
        if id.count >= 4 && id.count <= 40 { return true }
        else {
            errorLabel.showErrorMessage(message: "아이디는 4자 이상, 20자 이하로 적어주세요.")
            return false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    func checkIDDuplication() {
        
        let id = userIdTextField.text!.trimmingCharacters(in: .whitespaces)
        
        UserManager.shared.checkDuplication(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: "이미 사용 중인 아이디입니다.🥲")
                } else {
                    UserRegisterValues.shared.userId = id
                    DispatchQueue.main.async {
                        self.performSegue(
                            withIdentifier: K.SegueID.goToPasswordInputVC,
                            sender: self
                        )
                    }
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension IDInputViewController {
    
    func initialize() {
        createObserverForKeyboardStateChange()
        setClearNavigationBarBackground()
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    func createObserverForKeyboardStateChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name:UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name:UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.text = "환영합니다, 학우님!\n로그인에 사용할 아이디를 입력해주세요."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "로그인에 사용할 아이디"
        )

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }

    func initializeTextField() {
        view.addSubview(userIdTextField)
        userIdTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            userIdTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            userIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            userIdTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            userIdTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: padding),
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
