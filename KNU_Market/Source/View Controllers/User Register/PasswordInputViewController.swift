import UIKit
import TextFieldEffects
import SnapKit

class PasswordInputViewController: BaseViewController {
    
    //MARK: - Properties
    
    typealias RegisterError = ValidationError.OnRegister
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 20
        static let textFieldHeight: CGFloat     = 60
    }
    
    //MARK: - UI
    
    let titleLabelFirstLine: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.text = "\(UserRegisterValues.shared.userId)님 만나서 반갑습니다!"
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "\(UserRegisterValues.shared.userId)님"
        )
        return label
    }()
    
    let titleLabelSecondLine: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.text = "사용하실 비밀번호를 입력해 주세요!"
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "비밀번호"
        )
        return label
    }()
    
    let detailLabel: KMDetailLabel = {
        let label = KMDetailLabel(numberOfTotalLines: 2)
        label.text = RegisterError.incorrectPasswordFormat.rawValue
        return label
    }()
    
    lazy var passwordTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "비밀번호")
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        textField.inputAccessoryView = bottomButton
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var checkPasswordTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "비밀번호 확인")
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        textField.inputAccessoryView = bottomButton
        textField.isSecureTextEntry = true
        return textField
    }()
  
    lazy var bottomButton: KMBottomButton = {
        let button = KMBottomButton(buttonTitle: "다음")
        button.heightAnchor.constraint(equalToConstant: button.heightConstantForKeyboardAppeared).isActive = true
        button.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        view.addSubview(detailLabel)
        view.addSubview(passwordTextField)
        view.addSubview(checkPasswordTextField)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabelFirstLine.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        titleLabelSecondLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabelFirstLine.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabelSecondLine.snp.bottom).offset(25)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }

        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        checkPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            make.height.equalTo(Metrics.textFieldHeight)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
}

//MARK: - Target Methods

extension PasswordInputViewController {

    @objc func pressedBottomButton(_ sender: UIButton) {
        if  !validPassword() ||
            !checkPasswordLengthIsValid() ||
            !checkIfPasswordFieldsAreIdentical() { return }
        
        UserRegisterValues.shared.password = passwordTextField.text!
        let vc = NickNameInputViewController(userManager: UserManager())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showErrorMessage(with errorType: ValidationError.OnRegister) {
        detailLabel.text = errorType.rawValue
        detailLabel.textColor = UIColor(named: K.Color.appColor)
    }
}

//MARK: - User Input Validation

extension PasswordInputViewController {
    
    // 숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
    func validPassword() -> Bool {
        guard let userPW = passwordTextField.text else {
            showErrorMessage(with: RegisterError.empty)
            return false
        }
        
        let passwordREGEX = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordTesting = NSPredicate(format: "SELF MATCHES %@", passwordREGEX)
        
        if passwordTesting.evaluate(with: userPW) == true {
            return true
        } else {
            showErrorMessage(with: RegisterError.incorrectPasswordFormat)
            return false
        }
    }
    
    func checkPasswordLengthIsValid() -> Bool {
        guard let password = passwordTextField.text, let _ = checkPasswordTextField.text else {
            showErrorMessage(with: RegisterError.empty)
            return false
        }
        
        if password.count >= 8 && password.count <= 20 { return true }
        else {
            showErrorMessage(with: RegisterError.incorrectPasswordFormat)
            return false
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            showErrorMessage(with: RegisterError.passwordDoesNotMatch)
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        detailLabel.text = RegisterError.incorrectPasswordFormat.rawValue
        detailLabel.textColor = .lightGray
    }
}

