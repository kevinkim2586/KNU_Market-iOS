import UIKit
import TextFieldEffects

class PasswordInputViewController: UIViewController {
    
    private let titleLabelFirstLine     = KMTitleLabel(textColor: .darkGray)
    private let titleLabelSecondLine    = KMTitleLabel(textColor: .darkGray)
    private let detailLabel             = KMDetailLabel(numberOfTotalLines: 2)
    private let passwordTextField       = KMTextField(placeHolderText: "비밀번호")
    private let checkPasswordTextField  = KMTextField(placeHolderText: "비밀번호 확인")
    private let bottomButton            = KMBottomButton(buttonTitle: "다음")
    
    private let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
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
    
    @objc func pressedBottomButton(_ sender: UIButton) {
        if  !validPassword() ||
            !checkPasswordLengthIsValid() ||
            !checkIfPasswordFieldsAreIdentical() { return }
        
        UserRegisterValues.shared.password = passwordTextField.text!
        performSegue(
            withIdentifier: Constants.SegueID.goToNicknameInputVC,
            sender: self
        )
    }
    
    func showErrorMessage(message: String) {
        detailLabel.text = message
        detailLabel.textColor = UIColor(named: Constants.Color.appColor)
    }
}

//MARK: - User Input Validation

extension PasswordInputViewController {
    
    // 숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
    func validPassword() -> Bool {
        guard let userPW = passwordTextField.text else {
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요.🧐")
            return false
        }
        
        let passwordREGEX = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordTesting = NSPredicate(format: "SELF MATCHES %@", passwordREGEX)
        
        if passwordTesting.evaluate(with: userPW) == true {
            return true
        } else {
            showErrorMessage(message: "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔")
            return false
        }
    }
    
    func checkPasswordLengthIsValid() -> Bool {
        guard let password = passwordTextField.text, let _ = checkPasswordTextField.text else {
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요.🧐")
            return false
        }
        
        if password.count >= 8 && password.count <= 20 { return true }
        else {
            showErrorMessage(message: "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔")
            return false
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            showErrorMessage(message: "비밀번호가 일치하지 않습니다.🤔")
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        detailLabel.text = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요."
        detailLabel.textColor = .lightGray
    }
}


//MARK: - UI Configuration & Initialization

extension PasswordInputViewController {

    func initialize() {
        createObserverForKeyboardStateChange()
        initializeTitleLabels()
        initializeDetailLabel()
        initializeTextFields()
        initializeBottomButton()

    }
    
    func createObserverForKeyboardStateChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification ,
            object: nil
        )
    }
    
    func initializeTitleLabels() {
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        titleLabelFirstLine.text = "\(UserRegisterValues.shared.userId)님 만나서 반갑습니다!"
        titleLabelFirstLine.changeTextAttributeColor(
            fullText: titleLabelFirstLine.text!,
            changeText: "\(UserRegisterValues.shared.userId)님"
        )
        titleLabelSecondLine.text = "사용하실 비밀번호를 입력해 주세요!"
        titleLabelSecondLine.changeTextAttributeColor(
            fullText: titleLabelSecondLine.text!,
            changeText: "비밀번호"
        )
        
        NSLayoutConstraint.activate([
            titleLabelFirstLine.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabelFirstLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabelFirstLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            titleLabelSecondLine.topAnchor.constraint(equalTo: titleLabelFirstLine.bottomAnchor, constant: 10),
            titleLabelSecondLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabelSecondLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.text = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요."
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabelSecondLine.bottomAnchor, constant: 25),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeTextFields() {
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
            passwordTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            
            checkPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: padding),
            checkPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            checkPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            checkPasswordTextField.heightAnchor.constraint(equalToConstant: 60)
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
