import UIKit
import SnackBar_swift

class SettingsViewController: UIViewController {

    @IBOutlet var userNicknameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var unregisterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    
    @IBAction func pressedLogOutButton(_ sender: UIButton) {
        
        self.presentAlertWithCancelAction(title: "로그아웃 하시겠습니까?",
                                          message: "") { selectedOk in
            
            if selectedOk {
                
                UserManager.shared.logOut { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    
                    case .success(_):
                        DispatchQueue.main.async {
                            self.popToInitialViewController()
                        }
                        
                    case .failure(let error):
                        self.showSimpleBottomAlertWithAction(message: error.errorDescription,
                                                             buttonTitle: "재시도") {
                            DispatchQueue.main.async {
                                self.pressedLogOutButton(self.logOutButton)
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func pressedUnregisterButton(_ sender: UIButton) {
        
        self.presentAlertWithCancelAction(title: "정말 회원탈퇴를 하시겠습니까?",
                                          message: "") { selectedOk in
            
            if selectedOk {
                
                UserManager.shared.unregisterUser { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    switch result {
                    
                    case .success(_):
                        DispatchQueue.main.async {
                            self.popToInitialViewController()
                        }
                        
                    case .failure(let error):
                        self.showSimpleBottomAlertWithAction(message: error.errorDescription,
                                                             buttonTitle: "재시도") {
                            DispatchQueue.main.async {
                                self.pressedUnregisterButton(self.unregisterButton)
                            }
                        }
                    }
                }
            }
        }

        
    }

    func initialize() {
        
        userNicknameLabel.text = User.shared.nickname
        
    }
}
