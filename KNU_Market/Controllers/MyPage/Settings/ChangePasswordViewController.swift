import UIKit
import  SnackBar_swift

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var checkPasswordTextField: UITextField!
    @IBOutlet var changeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    @IBAction func pressedChangeButton(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if !validPassword() || !checkPasswordLengthIsValid() || !checkIfPasswordFieldsAreIdentical() { return }
        
        let newPassword = passwordTextField.text!
    
        showProgressBar()
        
        UserManager.shared.updateUserPassword(with: newPassword) { result in
            
            switch result {
            
            case .success(_):
                self.showSimpleBottomAlert(with: "비밀번호 변경 성공 🎉")
          
            case .failure(let error):
                self.showSimpleBottomAlert(with: "비밀번호 변경 실패. 잠시 후 다시 시도해주세요. 🥲")
                print("Failed to update user password with error: \(error.errorDescription)")
            }
            dismissProgressBar()
        }
    }
    
    func validPassword() -> Bool {
        
        guard let userPW = passwordTextField.text else {
            showSimpleBottomAlert(with: "빈 칸이 없는지 확인해 주세요. 🧐")
            return false
        }
        
        let passwordREGEX = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordTesting = NSPredicate(format: "SELF MATCHES %@", passwordREGEX)
        
        if passwordTesting.evaluate(with: userPW) == true {
            return true
        } else {
            showSimpleBottomAlert(with: "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔")
            return false
        }
    }
    
    func checkPasswordLengthIsValid() -> Bool {
        
        guard let password = passwordTextField.text, let _ = checkPasswordTextField.text else {
            showSimpleBottomAlert(with: "빈 칸이 없는지 확인해 주세요. 🧐")
            return false
        }
        
        if password.count >= 8 && password.count <= 20 { return true }
        else {
            showSimpleBottomAlert(with: "숫자와 문자를 조합하여\n8자 이상, 20자 이하로 적어주세요.🤔")
            return false
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            showSimpleBottomAlert(with: "비밀번호가 일치하지 않습니다. 🤔")
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
}

//MARK: - UI Configuration

extension ChangePasswordViewController {
    
    func initialize() {
        
        initializeTextFields()
        initializeButton()
        createObserversForPresentingVerificationAlert()
    }
    
    func initializeTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        checkPasswordTextField.isSecureTextEntry = true
    }
    
    func initializeButton() {
        
        changeButton.layer.cornerRadius = 10
    }
}
