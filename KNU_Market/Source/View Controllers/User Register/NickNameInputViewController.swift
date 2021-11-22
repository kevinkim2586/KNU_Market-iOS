import UIKit
import TextFieldEffects
import SnapKit

class NickNameInputViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    typealias RegisterError = ValidationError.OnRegister
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 20
        static let textFieldHeight: CGFloat     = 60
    }
    
    //MARK: - UI
    
    let titleLabelFirstLine: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.text = "크누마켓 내에서"
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "크누마켓"
        )
        return label
    }()
    
    let titleLabelSecondLine: KMTitleLabel = {
        let label = KMTitleLabel(textColor: .darkGray)
        label.text = "사용하실 닉네임을 입력해주세요!"
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "닉네임"
        )
        return label
    }()
    
    let detailLabel: KMDetailLabel = {
        let label = KMDetailLabel(numberOfTotalLines: 1)
        label.text = "2자 이상, 15자 이하로 적어주세요."
        return label
    }()
    
    lazy var nicknameTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "닉네임 입력")
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
        nicknameTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        view.addSubview(detailLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(errorLabel)
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
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            make.height.equalTo(60)
        }
                
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
}

//MARK: - Target Methods

extension NickNameInputViewController {
    
    @objc func pressedBottomButton(_ sender: UIButton) {
        nicknameTextField.resignFirstResponder()
        if !checkIfValidNickname() { return }
        checkNicknameDuplication()
    }
}


//MARK: - User Input Validation

extension NickNameInputViewController {
    
    func checkIfValidNickname() -> Bool {
        guard let nickname = nicknameTextField.text else { return false }
        
        if nickname.hasEmojis, nickname.hasSpecialCharacters {
            errorLabel.showErrorMessage(message: RegisterError.incorrectNicknameFormat.rawValue)
            return false
        }
        if nickname.count >= 2 && nickname.count <= 10 { return true }
        else {
            errorLabel.showErrorMessage(message: RegisterError.incorrectNicknameLength.rawValue)
            return false
        }
    }
    
    func checkNicknameDuplication() {
        let nickname = nicknameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        userManager?.checkDuplication(nickname: nickname) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: RegisterError.existingNickname.rawValue)
                } else {
                    UserRegisterValues.shared.nickname = nickname
                    let vc = EmailForLostPasswordViewController(userManager: UserManager())
                    self.navigationController?.pushViewController(vc, animated: true)
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
