import UIKit
import TextFieldEffects

class IDInputViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userIdTextField: HoshiTextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            nextButtonBottomAnchor.constant = keyboardSize.height
            nextButtonHeight.constant = 60
            nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
    }

    @IBAction func pressedNextButton(_ sender: UIButton) {
        if !checkIDLengthIsValid() { return }
        checkIDDuplication()
    }
}

//MARK: - User Input Validation

extension IDInputViewController {
    
    func checkIDLengthIsValid() -> Bool {
        
        return false
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
        //TODO: - API 통신 후 성공이면 다음 VC로 이동
        
    
    
        performSegue(
            withIdentifier: Constants.SegueID.goToPasswordInputVC,
            sender: self
        )
    }
    
    
}

//MARK: - UI Configuration

extension IDInputViewController {
    
    func initialize() {
        createObserverForKeyboardStateChange()
        addDismissButtonToRightNavBar()
        setClearNavigationBarBackground()
        initializeTitleLabel()
    }
    
    func createObserverForKeyboardStateChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name:UIResponder.keyboardWillHideNotification ,
            object: nil
        )
    }
    
    func initializeTitleLabel() {
        titleLabel.text = "환영합니다, 학우님!\n로그인에 사용할 아이디를 입력해주세요."
        titleLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: "로그인에 사용할 아이디"
        )
    }
    
}
