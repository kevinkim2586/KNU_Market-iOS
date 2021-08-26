import UIKit
import TextFieldEffects

class PasswordInputViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var checkPasswordTextField: HoshiTextField!
    
    
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
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        if !validPassword() || !checkPasswordLengthIsValid() || !checkIfPasswordFieldsAreIdentical() { return }
        performSegue(withIdentifier: Constants.SegueID.goToProfilePictureVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserRegisterValues.shared.password = passwordTextField.text!
    }
}

//MARK: - UI Configuration & Initialization

extension PasswordInputViewController {

    func initialize() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification , object: nil)
        
        
        initializeLabels()
        initializeTextFields()
    }
    
    func initializeTextFields() {
        
        passwordTextField.addTarget(self,
                              action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
        checkPasswordTextField.addTarget(self,
                              action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
     
    }
    
    func initializeLabels() {
        
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        secondLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        secondLineLabel.textColor = .darkGray
        
        firstLineLabel.text = "\(UserRegisterValues.shared.nickname)님 만나서 반갑습니다!"
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "\(UserRegisterValues.shared.nickname)님")
        secondLineLabel.text = "사용하실 비밀번호를 입력해 주세요!"
        secondLineLabel.changeTextAttributeColor(fullText: secondLineLabel.text!, changeText: "비밀번호")
    
        thirdLineLabel.text = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요."
        thirdLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        thirdLineLabel.textColor = .lightGray
    }
}

//MARK: - User Input Validation

extension PasswordInputViewController {
    
    // 숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
    func validPassword() -> Bool {
        
        guard let userPW = passwordTextField.text else {
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요. 🧐")
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
            
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요. 🧐")
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
            showErrorMessage(message: "비밀번호가 일치하지 않습니다. 🤔")
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
    
    func showErrorMessage(message: String) {
    
        thirdLineLabel.text = message
        thirdLineLabel.textColor = UIColor(named: Constants.Color.appColor)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        thirdLineLabel.text = "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요."
        thirdLineLabel.textColor = .lightGray
    }
}
