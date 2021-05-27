import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var checkPasswordTextField: UITextField!
    @IBOutlet var changeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    
    @IBAction func pressedChangeButton(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        let newPassword = passwordTextField.text!
    
        showProgressBar()
        
        UserManager.shared.updateUserPassword(with: newPassword) { result in
            
            switch result {
            
            case .success(_):
                self.showSuccessCard(title: "성공", message: "비밀번호가 변경되었습니다", iconText: "☑️")
          
                
            case .failure(let error):
                self.showErrorCard(title: "비밀번호 변경 실패", message: error.errorDescription)
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
            self.showWarningCard(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요")
            return false
        }
        
        guard password == checkPassword else {
            self.showWarningCard(title: "비밀번호가 일치하지 않습니다", message: "다시 입력해주세요")
            return false
        }
        
        guard password.count >= 5,
              password.count < 20,
              checkPassword.count >= 4,
              checkPassword.count < 20 else {
            self.showWarningCard(title: "비밀번호 길이 오류", message: "비밀번호는 5자 이상, 20자 미만으로 입력해주세요")
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
    }
    
    func initializeTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        checkPasswordTextField.isSecureTextEntry = true
    }
    
    func initializeButton() {
        
        changeButton.layer.cornerRadius = 10
    }
    
    
}
