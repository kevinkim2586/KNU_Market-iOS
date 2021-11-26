import UIKit
import TextFieldEffects
import SnapKit

class EmailForLostPasswordViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    typealias RegisterError = ValidationError.OnRegister
    
    //MARK: - Constants
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 20
    }
    
    //MARK: - UI
    
    let titleLabel: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.text = "비밀번호 분실 시 임시 비밀번호를 받을\n이메일 주소를 입력해주세요!"
        label.numberOfLines = 2
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "이메일 주소"
        )
        return label
    }()
    
    lazy var emailTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "이메일 주소 입력")
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        textField.inputAccessoryView = bottomButton
        return textField
    }()

    let errorLabel: KMErrorLabel = {
        let label = KMErrorLabel()
        label.isHidden = true
        return label
    }()
    
    lazy var bottomButton: KMBottomButton = {
        let button = KMBottomButton(buttonTitle: "크누마켓 시작하기")
        button.heightAnchor.constraint(equalToConstant: button.heightConstantForKeyboardAppeared).isActive = true
        button.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    
    init(userManager: UserManager) {
        super.init()
        self.userManager = userManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(54)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            make.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }

    }
    
    override func setupStyle() {
        super.setupStyle()
    }


}

//MARK: - Registration Method

extension EmailForLostPasswordViewController {

    func registerUser() {
        showProgressBar()

        let model = RegisterRequestDTO(
            id: UserRegisterValues.shared.userId,
            password: UserRegisterValues.shared.password,
            nickname: UserRegisterValues.shared.nickname,
            fcmToken: UserRegisterValues.shared.fcmToken,
            emailForPasswordLoss: UserRegisterValues.shared.emailForPasswordLoss
        )
    
        userManager?.register(with: model) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success:
                DispatchQueue.main.async { self.showCongratulateRegisterVC() }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func showCongratulateRegisterVC() {
        let vc = CongratulateUserViewController(userManager: UserManager())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

//MARK: - Target Methods

extension EmailForLostPasswordViewController {
    
    @objc func pressedBottomButton(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        if !checkIfValidEmail() { return }
        checkEmailDuplication(email: emailTextField.text!)
    }
}

//MARK: - User Input Validation

extension EmailForLostPasswordViewController {
    
    func checkIfValidEmail() -> Bool {
        guard let email = emailTextField.text else { return false }
        if !email.isValidEmail {
            errorLabel.showErrorMessage(message: RegisterError.invalidEmailFormat.rawValue)
            return false
        }
        return true
    }
    
    func checkEmailDuplication(email: String) {
        
        userManager?.checkDuplication(emailForPasswordLoss: email) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: RegisterError.existingEmail.rawValue)
                } else {
                    UserRegisterValues.shared.emailForPasswordLoss = email
                    self.registerUser()
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
}
