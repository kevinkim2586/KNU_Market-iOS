import UIKit
import TextFieldEffects

class EmailInputViewController: UIViewController {
    
    private let titleLabel              = KMTitleLabel(textColor: .darkGray)
    private let detailLabelFirstLine    = KMDetailLabel(numberOfTotalLines: 2)
    private let detailLabelSecondLine   = KMDetailLabel(numberOfTotalLines: 1)
    private let emailTextField          = KMTextField(placeHolderText: "웹메일 아이디 @knu.ac.kr")
    private let errorLabel              = KMErrorLabel()
    private let bottomButton            = KMBottomButton(buttonTitle: "인증 메일 보내기")
    
    private var email: String?
    
    private let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    @objc func pressedSendEmailButton() {
        if !checkIfValidEmail() { return }
        presentAlertWithCancelAction(
            title: emailTextField.text!,
            message: "위 이메일이 맞나요? 마지막으로 한 번 더 확인해 주세요."
        ) { [weak self] selectedOk in
            guard let self = self else { return }
            if selectedOk {
                self.emailTextField.resignFirstResponder()
                
                guard let email = self.emailTextField.text?.trimmingCharacters(in: .whitespaces) else {
                    self.showSimpleBottomAlert(with: "올바른 이메일 형식인지 다시 한 번 확인해주세요.")
                    return
                }
                self.email = email
                self.sendVerificationEmail(to: email)
            }
        }
    }
    
    func sendVerificationEmail(to email: String) {
        showProgressBar()
        UserManager.shared.sendVerificationEmail(email: email) { [weak self] result in
            dismissProgressBar()
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.goToCheckEmailVC()
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func goToCheckEmailVC() {
        guard let vc = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.checkEmailVC
        ) as? CheckEmailViewController else { return }
        
        guard let email = email else { return }
        
        vc.email = email
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UI Configuration & Initialization

extension EmailInputViewController {
    
    func initialize() {
        title = "웹메일 인증"
        initializeTitleLabel()
        initializeDetailLabels()
        initializeTextField()
        initializeErrorLabel()
        initializeBottomButton()
    }
    
    func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "웹메일(@knu.ac.kr)을 입력해주세요."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "웹메일(@knu.ac.kr)을 입력"
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
        
    }
    
    func initializeDetailLabels() {
        view.addSubview(detailLabelFirstLine)
        view.addSubview(detailLabelSecondLine)
        
        detailLabelFirstLine.text = "✻ 메일이 보이지 않는 경우 반드시 스팸 메일함을\n확인해주세요."
        detailLabelSecondLine.text = "✻ 웹메일 ID는 yes 포털 아이디와 동일합니다."

        detailLabelFirstLine.changeTextAttributeColor(
            fullText: detailLabelFirstLine.text!,
            changeText: "반드시 스팸 메일함을\n확인"
        )
        detailLabelSecondLine.changeTextAttributeColor(
            fullText: detailLabelSecondLine.text!,
            changeText: "yes 포털 아이디와 동일"
        )
    
        NSLayoutConstraint.activate([
            detailLabelFirstLine.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            detailLabelFirstLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabelFirstLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            detailLabelSecondLine.topAnchor.constraint(equalTo: detailLabelFirstLine.bottomAnchor, constant: 15),
            detailLabelSecondLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabelSecondLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
        
    }
    
    func initializeTextField() {
        view.addSubview(emailTextField)
        emailTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: detailLabelSecondLine.bottomAnchor, constant: 30),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding + 130)),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    func initializeErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.isHidden = true
        
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: padding),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(padding))
        ])
    }
    
    func initializeBottomButton() {
        bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardAppeared).isActive = true
        bottomButton.addTarget(
            self,
            action: #selector(pressedSendEmailButton),
            for: .touchUpInside
        )
        emailTextField.inputAccessoryView = bottomButton
    }
    


}

//MARK: - User Input Validation

extension EmailInputViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    func checkIfValidEmail() -> Bool {
        
        guard let email = emailTextField.text else {
            errorLabel.showErrorMessage(message: "빈 칸이 없는지 확인해 주세요.🤔")
            return false
        }
        
        guard email.contains("@knu.ac.kr") else {
            errorLabel.showErrorMessage(message: "경북대학교 이메일이 맞는지 확인해 주세요.🧐")
            return false
        }
        
        guard email.count > 10 else {
            errorLabel.showErrorMessage(message: "유효한 이메일인지 확인해 주세요. 👀")
            return false
        }
        return true
    }
    

    
}

