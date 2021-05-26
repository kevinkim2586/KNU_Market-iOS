import UIKit

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
        
        showProgressBar()
        
        if !didCheckNicknameDuplicate {
            self.presentSimpleAlert(title: "닉네임 중복 확인", message: "닉네임 중복을 먼저 확인해주세요.")
            dismissProgressBar()
            return
        }
        
        guard let nickname = self.nickname else {
            self.presentSimpleAlert(title: "빈 칸 오류", message: "빈 칸이 없는지 확인해주세요.")
            return
        }
        
        //        let editUserModel = EditUserInfoModel(nickname: nickname)
        //
        //        UserManager.shared.updateNickname(with: editUserModel) { isSuccess in
        //
        //            if isSuccess {
        //
        //                dismissProgressBar()
        //                self.navigationController?.popViewController(animated: true)
        //
        //            } else {
        //                DispatchQueue.main.async {
        //                    self.presentSimpleAlert(title: "닉네임 변경 실패", message: "네트워크 오류")
        //                }
        //            }
        //            dismissProgressBar()
        //        }
    }
    
    func checkIfDuplicate() {
        
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        UserManager.shared.checkDuplicate(nickname: nickname!) { result in
            
            switch result {
            
            case .success(let isNotDuplicate):
                
                if isNotDuplicate {
                    DispatchQueue.main.async {
                        self.checkAlreadyInUseButton.setTitle("사용하셔도 좋습니다 👍", for: .normal)
                        self.didCheckNicknameDuplicate = true
                    }
                } else {
                    DispatchQueue.main.async {
                        
                        self.checkAlreadyInUseButton.setTitle("이미 사용 중인 닉네임입니다 😅", for: .normal)
                        self.didCheckNicknameDuplicate = false
                    }
                }
                
            case .failure(let error):
                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
            }
        }
        
        
        func validateUserInput() -> Bool {
            
            guard let nickname = nicknameTextField.text else {
                return false
            }
            guard !nickname.isEmpty else {
                self.presentSimpleAlert(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요.")
                return false
            }
            guard nickname.count >= 2, nickname.count <= 15 else {
                self.presentSimpleAlert(title: "닉네임 길이 오류", message: "닉네임은 2자 이상, 15자 이하로 작성해주세요.")
                return false
            }
            self.nickname = nickname
            return true
        }
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
    }
    
    func initializeButton() {
        
        changeButton.layer.cornerRadius = 10
    }
}
