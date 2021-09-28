import UIKit
import TextFieldEffects

class IDInputViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIdTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    private let bottomButton = KMBottomButton(buttonTitle: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
  

            bottomButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -keyboardSize.height
            ).isActive = true
            bottomButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            view.layoutIfNeeded()
            bottomButton.updateTitleEdgeInsetsForKeyboardAppeared()

        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        bottomButton.updateTitleEdgeInsetsForKeyboardHidden()
//        nextButtonBottomAnchor.constant = 0
//        nextButtonHeight.constant = 80
//        nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    @objc func pressedBottomButton() {
        userIdTextField.resignFirstResponder()
        if !checkIfValidId() { return }
        checkIDDuplication()
    }
}

//MARK: - User Input Validation

extension IDInputViewController {
    
    func checkIfValidId() -> Bool {
        guard let id = userIdTextField.text else { return false}
        
        if id.hasSpecialCharacters {
            showErrorMessage(message: "아이디에 특수 문자와 한글을 포함할 수 없어요.")
            return false
        }
        
        if id.count >= 4 && id.count <= 40 { return true }
        else {
            showErrorMessage(message: "아이디는 4자 이상, 20자 이하로 적어주세요.")
            return false
        }
    }
    
    func showErrorMessage(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        errorLabel.textColor = UIColor(named: Constants.Color.appColor)
    }
    
    func dismissErrorMessage() {
        errorLabel.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        dismissErrorMessage()
    }
    
    func checkIDDuplication() {
        
        let id = userIdTextField.text!.trimmingCharacters(in: .whitespaces)
        
        UserManager.shared.checkDuplication(id: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    self.showErrorMessage(message: "이미 사용 중인 아이디입니다.🥲")
                } else {
                    UserRegisterValues.shared.userId = id
                    DispatchQueue.main.async {
                        self.performSegue(
                            withIdentifier: Constants.SegueID.goToPasswordInputVC,
                            sender: self
                        )
                    }
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
}

//MARK: - UI Configuration

extension IDInputViewController {
    
    func initialize() {
        initializeBottomButton()
        createObserverForKeyboardStateChange()
        initializeTextField()
        setClearNavigationBarBackground()
        initializeTitleLabel()
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
            bottomButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func createObserverForKeyboardStateChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name:UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name:UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func initializeTextField() {
        userIdTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    func initializeTitleLabel() {
        errorLabel.isHidden = true
        titleLabel.text = "환영합니다, 학우님!\n로그인에 사용할 아이디를 입력해주세요."
        titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "로그인에 사용할 아이디"
        )
    }
    
}
