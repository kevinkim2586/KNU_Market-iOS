import UIKit
import TextFieldEffects

class NickNameInputViewController: UIViewController {
    
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var nicknameTextField: HoshiTextField!
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
        if !checkNicknameLengthIsValid() { return }
        checkNicknameDuplication()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserRegisterValues.shared.nickname = nicknameTextField.text!
    }
}


//MARK: - User Input Validation

extension NickNameInputViewController {
    
    func checkNicknameLengthIsValid() -> Bool {
        guard let nickname = nicknameTextField.text else { return false }
        
        if nickname.count >= 2 && nickname.count <= 15 { return true }
        else {
            showErrorMessage(message: "닉네임은 2자 이상, 15자 이하로 적어주세요.")
            return false
        }
    }
    
    func showErrorMessage(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
        errorLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        errorLabel.textColor = UIColor(named: Constants.Color.appColor)
        
    }
    
    func checkNicknameDuplication() {
        
        UserManager.shared.checkNicknameDuplicate(nickname: nicknameTextField.text!) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    self.showErrorMessage(message: "이미 사용 중인 닉네임입니다. 🥲")
                }
                else {
                    DispatchQueue.main.async {
                        self.showCongratulateRegisterVC()
                    }
                }
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func showCongratulateRegisterVC() {
        guard let vc = storyboard?.instantiateViewController(
                identifier: Constants.StoryboardID.congratulateUserVC
        ) as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func dismissErrorMessage() {
        errorLabel.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        dismissErrorMessage()
    }
}

//MARK: - UI Configuration & Initialization

extension NickNameInputViewController {
    
    func initialize() {
        createObserverForKeyboardStateChange()
        setClearNavigationBarBackground()
        initializeLabels()
        initializeTextField()
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
    
    func initializeTextField() {
        nicknameTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
  
    
    func initializeLabels() {
        
        errorLabel.isHidden = true
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        secondLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        secondLineLabel.textColor = .darkGray
        
        firstLineLabel.text = "크누마켓에 오신 것을 환영해요!!"
        firstLineLabel.changeTextAttributeColor(
            fullText: firstLineLabel.text!,
            changeText: "크누마켓"
        )
        secondLineLabel.text = "사용하실 닉네임을 입력해주세요!"
        secondLineLabel.changeTextAttributeColor(
            fullText: secondLineLabel.text!,
            changeText: "닉네임"
        )
        
        thirdLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        thirdLineLabel.textColor = .lightGray

    }
}
