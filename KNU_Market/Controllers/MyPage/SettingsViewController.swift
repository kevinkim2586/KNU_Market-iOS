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

    @IBAction func pressedInfoButton(_ sender: UIButton) {
        
        presentAlertWithCancelAction(title: "알림이 오지 않나요?",
                                     message: "설정으로 이동 후 알림 받기가 꺼져있지는 않은지 확인해 주세요. 그래도 안 되면 어플 재설치를 부탁드립니다.") { selectedOk in
            
            if selectedOk {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                          options: [:],
                                          completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func pressedResendEmailButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VerifyEmail", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.emailInputVC
        ) as? EmailInputViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func initialize() {
        userNicknameLabel.text = User.shared.nickname
    }
}
