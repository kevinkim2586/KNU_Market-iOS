import UIKit
import TextFieldEffects
import SnapKit

class IDInputViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    typealias RegisterError = ValidationError.OnRegister
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat = 16
    }
    
    //MARK: - UI
    
    let titleLabel: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.numberOfLines = 2
        label.text = "환영합니다, 학우님!\n로그인에 사용할 아이디를 입력해주세요."
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "로그인에 사용할 아이디"
        )
        return label
    }()
    
    lazy var userIdTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "아이디 입력")
        textField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        textField.autocapitalizationType = .none
        textField.inputAccessoryView = bottomButton
        return textField
    }()
    
    let errorLabel: KMErrorLabel = {
        let label = KMErrorLabel()
        label.isHidden = true
        label.numberOfLines = 2
        return label
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
    
    lazy var dismissBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "xmark"),
        style: .plain,
        target: self,
        action: #selector(dismissVC)
    )
       
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
        userIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = dismissBarButtonItem
        
        view.addSubview(titleLabel)
        view.addSubview(userIdTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        userIdTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(55)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            make.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(userIdTextField.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
        setClearNavigationBarBackground()
    }
}

//MARK: - Target Methods

extension IDInputViewController {
    
    @objc private func pressedBottomButton() {
        userIdTextField.resignFirstResponder()
        if !checkIfValidId() { return }
        checkIDDuplication()
    }
}

//MARK: - User Input Validation

extension IDInputViewController {
    
    func checkIfValidId() -> Bool {
        guard let id = userIdTextField.text else { return false }
        
        if id.count < 4 || id.count > 50 {
            errorLabel.showErrorMessage(message: RegisterError.incorrectIdLength.rawValue)
            return false
        }
        
        if !id.isValidId {
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
        
        userManager?.checkDuplication(id: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: RegisterError.existingId.rawValue)
                } else {
                    UserRegisterValues.shared.userId = id
                    self.navigationController?.pushViewController(
                        PasswordInputViewController(),
                        animated: true
                    )
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
}
