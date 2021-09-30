import UIKit
import TextFieldEffects

class NickNameInputViewController: UIViewController {
    
    private let titleLabelFirstLine     = KMTitleLabel(textColor: .darkGray)
    private let titleLabelSecondLine    = KMTitleLabel(textColor: .darkGray)
    private let detailLabel             = KMDetailLabel(numberOfTotalLines: 1)
    private let nicknameTextField       = KMTextField(placeHolderText: "닉네임 입력")
    private let errorLabel              = KMErrorLabel()
    private let bottomButton            = KMBottomButton(buttonTitle: "다음")
    
    private let padding: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nicknameTextField.becomeFirstResponder()
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
            errorLabel.showErrorMessage(message: "유효하지 않은 닉네임이에요.")
            return false
        }
        
        if nickname.count >= 2 && nickname.count <= 15 { return true }
        else {
            errorLabel.showErrorMessage(message: "닉네임은 2자 이상, 15자 이하로 적어주세요.")
            return false
        }
    }
    
    func checkNicknameDuplication() {
        let nickname = nicknameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        UserManager.shared.checkDuplication(nickname: nickname) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    self.errorLabel.showErrorMessage(message: "이미 사용 중인 닉네임입니다.🥲")
                } else {
                    UserRegisterValues.shared.nickname = nickname
                    DispatchQueue.main.async {
                        self.performSegue(
                            withIdentifier: K.SegueID.goToEmailForLostPwVC,
                            sender: self
                        )
                    }
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

//MARK: - UI Configuration & Initialization

extension NickNameInputViewController {
    
    func initialize() {
        setClearNavigationBarBackground()
        initializeTitleLabels()
        initializeDetailLabel()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    

    func initializeTitleLabels() {
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        
        titleLabelFirstLine.text = "크누마켓 내에서"
        titleLabelFirstLine.changeTextAttributeColor(
            fullText: titleLabelFirstLine.text!,
            changeText: "크누마켓"
        )
        
        titleLabelSecondLine.text = "사용하실 닉네임을 입력해주세요!"
        titleLabelSecondLine.changeTextAttributeColor(
            fullText: titleLabelSecondLine.text!,
            changeText: "닉네임"
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
        detailLabel.text = "2자 이상, 15자 이하로 적어주세요."
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabelSecondLine.bottomAnchor, constant: 25),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }

    func initializeTextField() {
        view.addSubview(nicknameTextField)
        nicknameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            nicknameTextField.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 30),
            nicknameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nicknameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: padding),
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
        nicknameTextField.inputAccessoryView = bottomButton
    }
}
