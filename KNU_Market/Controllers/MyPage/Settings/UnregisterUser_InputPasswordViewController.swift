import UIKit
import TextFieldEffects
import Alamofire

class UnregisterUser_InputPasswordViewController: UIViewController {
    
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var detailLineLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedNextButton(_ sender: UIBarButtonItem) {
        
        guard let password = passwordTextField.text else {
            showErrorMessage(message: "비밀번호를 입력해 주세요.")
            return
        }
        
        UserManager.shared.login(id: User.shared.userID,
                                 password: password) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let vc = self.storyboard?.instantiateViewController(
                        identifier: K.StoryboardID.unregisterUserInputSuggestVC
                    ) as! UnregisterUser_InputSuggestionViewController
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self.showErrorMessage(message: "비밀번호가 일치하지 않습니다. 다시 시도해 주세요.")
                }
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension UnregisterUser_InputPasswordViewController {
    
    func initialize() {
        
        initializeLabels()
        initializeTextFields()
    }
    
    func initializeLabels() {
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.text = "회원탈퇴라니요..\n한 번만 더 생각해 주세요. 😥"
        
        detailLineLabel.text = "회원 탈퇴를 위해 비밀번호를 입력해 주세요."
        detailLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detailLineLabel.textColor = .lightGray
    }
    
    
    func initializeTextFields() {
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.addTarget(self,
                                    action: #selector(textFieldDidChange(_:)),
                                    for: .editingChanged)
    }
    
    func showErrorMessage(message: String) {
    
        detailLineLabel.text = message
        detailLineLabel.textColor = UIColor(named: K.Color.appColor)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        detailLineLabel.text = "회원 탈퇴를 위해 비밀번호를 입력해 주세요."
        detailLineLabel.textColor = .lightGray
    }
    
}
