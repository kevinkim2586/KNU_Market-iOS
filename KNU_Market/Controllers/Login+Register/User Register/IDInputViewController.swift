import UIKit
import TextFieldEffects

class IDInputViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let userIdTextField = KMTextField(placeHolderText: "아이디 입력")
    private let errorLabel      = KMErrorLabel()
    private let bottomButton    = KMBottomButton(buttonTitle: "다음")
    
    private let padding: CGFloat = 20
    
    typealias RegisterError = ValidationError.OnRegister
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIdTextField.becomeFirstResponder()
    }
}

//MARK: - IBActions & Target Methods

extension IDInputViewController {
    
    @objc func pressedBottomButton() {
        userIdTextField.resignFirstResponder()
        if !checkIfValidId() { return }
        checkIDDuplication()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - User Input Validation

extension IDInputViewController {
    
    func checkIfValidId() -> Bool {
        guard let id = userIdTextField.text else { return false }
        
        if id.count < 4 || id.count > 30 {
            errorLabel.showErrorMessage(message: RegisterError.incorrectIdLength.rawValue)
            return false
        }
        
        if !id.isValidEmail, !id.isValidId {
            errorLabel.showErrorMessage(message: RegisterError.incorrectIdFormat.rawValue)
            return false
        }
        return true
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
                    self.errorLabel.showErrorMessage(message: RegisterError.existingId.rawValue)
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
        setClearNavigationBarBackground()
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
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
        errorLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: padding),
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
        userIdTextField.inputAccessoryView = bottomButton
    }
}
