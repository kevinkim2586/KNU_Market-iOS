import UIKit

class FindPasswordViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let detailLabel     = KMDetailLabel(numberOfTotalLines: 2)
    private let userIdTextField = KMTextField(placeHolderText: "크누마켓 아이디")
    private let errorLabel      = KMErrorLabel()
    private let bottomButton    = KMBottomButton(buttonTitle: "임시 비밀번호 받기")
    
    private let padding: CGFloat = 20
    
    private var viewModel = FindUserInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIdTextField.becomeFirstResponder()
    }
}

//MARK: - FindUserInfoViewModelDelegate

extension FindPasswordViewController: FindUserInfoViewModelDelegate {
    
    func didFindUserPassword(emailPasswordSent: NSAttributedString) {
        presentKMAlertOnMainThread(
            title: "비밀번호 안내",
            message: "",
            buttonTitle: "닫기",
            attributedMessageString: emailPasswordSent
        )
    }
    
    func didFailFetchingData(errorMessage: String) {
        errorLabel.showErrorMessage(message: errorMessage)
    }
    
    func didFailValidatingUserInput(errorMessage: String) {
        errorLabel.showErrorMessage(message: errorMessage)
    }
}

//MARK: - Target Methods

extension FindPasswordViewController {
    
    @objc func pressedBottomButton() {
        viewModel.validateUserInput(findIdOption: .password, userId: userIdTextField.text)
    }
}

//MARK: - TextField Methods

extension FindPasswordViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}

//MARK: - UI Configuration & Initialization

extension FindPasswordViewController {
    
    func initialize() {
        title = "비밀번호 찾기"
        viewModel.delegate = self
        setClearNavigationBarBackground()
        initializeTitleLabel()
        initializeDetailLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.text = "크누마켓 아이디를 입력해주세요."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "크누마켓 아이디"
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.numberOfLines = 2
        detailLabel.text = "회원가입 시 입력했던 이메일로\n임시 비밀번호가 전송됩니다."
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: padding)
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
            userIdTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 55),
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
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        userIdTextField.inputAccessoryView = bottomButton

        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
    }
}
