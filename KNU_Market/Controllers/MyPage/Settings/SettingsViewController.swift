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
                
                DispatchQueue.main.async {
                    self.popToInitialViewController()
                }
            }
        }
    }

    func initialize() {
        
        userNicknameLabel.text = User.shared.nickname
        
    }
}
