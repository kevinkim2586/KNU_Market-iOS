import UIKit

class FindIdUsingWebMailViewController: UIViewController {
    
    private let titleLabel          = KMTitleLabel(textColor: .darkGray)
    private let userEmailTextField  = KMTextField(placeHolderText: "웹메일 아이디 @knu.ac.kr")
    private let errorLabel          = KMErrorLabel()
    private let bottomButton        = KMBottomButton(buttonTitle: "아이디 찾기")
    
    private let padding: CGFloat = 20
    
    private var viewModel = FindUserInfoViewModel(userManager: UserManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userEmailTextField.becomeFirstResponder()
    }
}

//MARK: - FindUserInfoViewModelDelegate

extension FindIdUsingWebMailViewController: FindUserInfoViewModelDelegate {
    
    func didFindUserId(id: NSAttributedString) {
        presentKMAlertOnMainThread(
            title: "아이디 안내",
            message: "",
            buttonTitle: "닫기",
            attributedMessageString: id
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

extension FindIdUsingWebMailViewController {
    
    @objc func pressedBottomButton() {
        viewModel.validateUserInput(findIdOption: .webMail, mail: userEmailTextField.text)
    }
}

//MARK: - TextField Methods

extension FindIdUsingWebMailViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}

//MARK: - UI Configuration & Initialization

extension FindIdUsingWebMailViewController {
    
    func initialize() {
        viewModel.delegate = self
        initializeTitleLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.text = "학생 인증에 사용했던\n웹메일 주소를 입력해주세요."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "웹메일 주소를 입력"
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeTextField() {
        view.addSubview(userEmailTextField)
        
        userEmailTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            userEmailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            userEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            userEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            userEmailTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: userEmailTextField.bottomAnchor, constant: padding),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeBottomButton() {
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        userEmailTextField.inputAccessoryView = bottomButton

        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
    }
}
