import UIKit

class FindIdUsingStudentIdViewController: UIViewController {
    
    private let titleLabel              = KMTitleLabel(textColor: .darkGray)
    private let userStudentIdTextField  = KMTextField(placeHolderText: "학번")
    private let userBirthDateTextField  = KMTextField(placeHolderText: "생년월일 (6자리)")
    private let errorLabel              = KMErrorLabel()
    private let bottomButton            = KMBottomButton(buttonTitle: "아이디 찾기")
    
    private let padding: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        
    }
    

}

//MARK: - Target Methods

extension FindIdUsingStudentIdViewController {
    
    @objc func pressedBottomButton() {
        
    }
}

//MARK: - User Input Validation

extension FindIdUsingStudentIdViewController {
    
    
}

//MARK: - TextField Methods

extension FindIdUsingStudentIdViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}

//MARK: - UI Configuration & Initialization

extension FindIdUsingStudentIdViewController {
    
    func initialize() {
        
        initializeTitleLabel()
        initializeTextFields()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 1
        titleLabel.text = "학번과 생년월일을 입력해주세요."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "학번과 생년월일을 입력"
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeTextFields() {
        view.addSubview(userStudentIdTextField)
        view.addSubview(userBirthDateTextField)
        
        [userStudentIdTextField, userBirthDateTextField].forEach { textField in
            textField.addTarget(
                self,
                action: #selector(textFieldDidChange(_:)),
                for: .editingChanged
            )
        }
        
        NSLayoutConstraint.activate([
            userStudentIdTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 55),
            userStudentIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            userStudentIdTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            userStudentIdTextField.heightAnchor.constraint(equalToConstant: 60),
            
            userBirthDateTextField.topAnchor.constraint(equalTo: userStudentIdTextField.bottomAnchor, constant: padding),
            userBirthDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            userBirthDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            userBirthDateTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: userBirthDateTextField.bottomAnchor, constant: padding),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeBottomButton() {
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        userStudentIdTextField.inputAccessoryView = bottomButton
        userBirthDateTextField.inputAccessoryView = bottomButton
        bottomButton.updateTitleEdgeInsetsForKeyboardAppeared()
        
        bottomButton.addTarget(self, action: #selector(pressedBottomButton), for: .touchUpInside)
    }
}
