import UIKit
import SnackBar_swift

class SettingsViewController: UIViewController {

    @IBOutlet var userNicknameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialize()
    }

    @IBAction func pressedLogOutButton(_ sender: UIButton) {
        
        UserManager.shared.logOut { result in
            
            switch result {
            
            case .success(_):
                
                self.presentAlertWithCancelAction(title: "로그아웃 하시겠습니까?", message: "") { selectedOk in
                    
                    if selectedOk {
                        
                        DispatchQueue.main.async {
                            
                        
                            self.popToInitialViewController()
                        }
                    }
                }
            case .failure(let error):
                SnackBar.make(in: self.view,
                              message: error.errorDescription,
                              duration: .lengthLong).setAction(with: "재시도", action: {
                                DispatchQueue.main.async {
                                    self.pressedLogOutButton(self.logOutButton)
                                }
                              }).show()
            }
        }
    }

    @IBAction func pressedUnregisterButton(_ sender: UIButton) {
    
        
    }

    func initialize() {
        
        userNicknameLabel.text = User.shared.nickname
        
    }
}
