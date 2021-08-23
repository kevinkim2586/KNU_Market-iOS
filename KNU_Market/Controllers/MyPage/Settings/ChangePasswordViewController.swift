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
        
        if !validateUserInput() { return }
        
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
    
    func validateUserInput() -> Bool {
        
        guard let password = passwordTextField.text,
              let checkPassword = checkPasswordTextField.text else {
            return false
        }
        
        guard !password.isEmpty,
              !checkPassword.isEmpty else {
            self.showSimpleBottomAlert(with: "빈 칸이 없는지 확인해주세요 🥲")
            return false
        }
        
        guard password == checkPassword else {
            self.showSimpleBottomAlert(with: "비밀번호가 일치하지 않습니다 🤔")
            return false
        }
        
        guard password.count >= 5,
              password.count < 20,
              checkPassword.count >= 4,
              checkPassword.count < 20 else {
            self.showSimpleBottomAlert(with: "비밀번호는 5자 이상, 30자 미만으로 입력해주세요 ❗️")
            return false
        }
        return true
    }
    
}

//MARK: - UI Configuration

extension ChangePasswordViewController {
    
    func initialize() {
        
        initializeTextFields()
        initializeButton()
        createObserversForPresentingEmailVerification()
    }
    
    func initializeTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        checkPasswordTextField.isSecureTextEntry = true
    }
    
    func initializeButton() {
        
        changeButton.layer.cornerRadius = 10
    }
}
