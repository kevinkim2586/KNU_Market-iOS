import UIKit
import TextFieldEffects

class PasswordInputViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var checkPasswordTextField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedNext(_ sender: UIBarButtonItem) {
        
        if !checkPasswordLengthIsValid() || !checkIfPasswordFieldsAreIdentical() { return }
        performSegue(withIdentifier: Constants.SegueID.goToProfilePictureVC, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserRegisterValues.shared.password = passwordTextField.text!
    }
}


//MARK: - UI Configuration & Initialization

extension PasswordInputViewController {

    func initialize() {
        
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
    
        thirdLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        thirdLineLabel.textColor = .lightGray
    }
}

//MARK: - User Input Validation

extension PasswordInputViewController {
    
    func checkPasswordLengthIsValid() -> Bool {
        
        guard let password = passwordTextField.text, let _ = checkPasswordTextField.text else {
            
            showErrorMessage(message: "빈 칸이 없는지 확인해 주세요. 🧐")
            return false
        }
        
        if password.count >= 8 && password.count <= 20 { return true }
        else {
            showErrorMessage(message: "4자 이상, 30자 이하로 적어주세요. 🤔")
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
        
        thirdLineLabel.text = "4자 이상, 30자 이하로 적어주세요."
        thirdLineLabel.textColor = .lightGray
    }
}
