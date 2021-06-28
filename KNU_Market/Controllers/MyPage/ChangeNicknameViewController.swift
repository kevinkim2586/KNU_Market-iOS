import UIKit
import SnackBar_swift

class ChangeNicknameViewController: UIViewController {
    
    @IBOutlet var nicknameTextField: UITextField!
    @IBOutlet var checkAlreadyInUseButton: UIButton!
    @IBOutlet var changeButton: UIButton!
    
    private var nickname: String?
    private var didCheckNicknameDuplicate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    }
    
    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        
        checkIfDuplicate()
    }
    
    @IBAction func pressedChangeButton(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if !didCheckNicknameDuplicate {
            SnackBar.make(in: self.view,
                          message: "🤔 닉네임 중복 확인을 먼저해주세요.",
                          duration: .lengthLong).show()
            return
        }
        
        if !validateUserInput() { return }
        
        guard let nickname = self.nickname else {
            SnackBar.make(in: self.view,
                          message: "🤔 빈 칸이 없는지 확인해주세요.",
                          duration: .lengthLong).show()
            return
        }
        
        showProgressBar()
        
        UserManager.shared.updateUserNickname(with: nickname) { result in
            
            switch result {
            
            case .success(_):
                SnackBar.make(in: self.view,
                              message: "닉네임이 변경되었습니다 🎉",
                              duration: .lengthLong).show()
                
            case .failure(let error):
                SnackBar.make(in: self.view,
                              message: "닉네임 변경 실패. 잠시 후 다시 시도해주세요 🥲",
                              duration: .lengthLong).show()
                print("ChangeNickNameVC failed to update nickname with error: \(error.errorDescription)")
            }
        }
        dismissProgressBar()
        

    }
    
    func checkIfDuplicate() {
        
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        UserManager.shared.checkDuplicate(nickname: nickname!) { result in
            
            switch result {
            
            case .success(let isNotDuplicate):
                
                if isNotDuplicate {
                    DispatchQueue.main.async {
                        self.checkAlreadyInUseButton.setTitle("사용하셔도 좋습니다 🎉",
                                                              for: .normal)
                        self.didCheckNicknameDuplicate = true
                    }
                } else {
                    DispatchQueue.main.async {
                        
                        self.checkAlreadyInUseButton.setTitle("이미 사용 중인 닉네임입니다 😅",
                                                              for: .normal)
                        self.didCheckNicknameDuplicate = false
                    }
                }
                
            case .failure(let error):
                SnackBar.make(in: self.view,
                              message: "일시적인 네트워크 오류. 잠시 후 다시 시도해주세요 🥲",
                              duration: .lengthLong).show()
                print("Error in checking duplicate: \(error.errorDescription)")
            }
        }
    }
    
    
    func validateUserInput() -> Bool {
        
        guard let nickname = nicknameTextField.text else {
            return false
        }
        guard !nickname.isEmpty else {
            SnackBar.make(in: self.view,
                          message: "빈 칸이 없는지 확인해주세요 🥲",
                          duration: .lengthLong).show()
            return false
        }
        guard nickname.count >= 2, nickname.count <= 15 else {
            SnackBar.make(in: self.view,
                          message: "닉네임은 2자 이상, 15자 이하로 작성해주세요❗️ ",
                          duration: .lengthLong).show()
            return false
        }
        self.nickname = nickname
        return true
    }
}


//MARK: - UITextFieldDelegate

extension ChangeNicknameViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nicknameTextField {
            didCheckNicknameDuplicate = false
            checkAlreadyInUseButton.setTitle("중복 확인", for: .normal)
            checkAlreadyInUseButton.titleLabel?.tintColor = UIColor(named: Constants.Color.appColor)
        }
    }
}

//MARK: - UI Configuration

extension ChangeNicknameViewController {
    
    func initialize() {
        
        initializeTextField()
        initializeButton()
    }
    
    func initializeTextField() {
        nicknameTextField.delegate = self
        nicknameTextField.placeholder = User.shared.nickname
    }
    
    func initializeButton() {
        changeButton.layer.cornerRadius = 10
    }
}
