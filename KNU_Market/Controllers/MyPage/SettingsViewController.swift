import UIKit
import SnackBar_swift

class SettingsViewController: UIViewController {

    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet var userNicknameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    
    @IBOutlet weak var changeIdButton: UIButton!
    @IBOutlet weak var changeEmailButton: UIButton!
    

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
}

//MARK: - IBActions

extension SettingsViewController {
    
    @IBAction func pressedLogOutButton(_ sender: UIButton) {
        
        self.presentAlertWithCancelAction(
            title: "로그아웃 하시겠습니까?",
            message: ""
        ) { selectedOk in
            if selectedOk {
                DispatchQueue.main.async { self.popToInitialViewController() }
            }
        }
    }
    
    @IBAction func pressedInfoButton(_ sender: UIButton) {
        
        presentAlertWithCancelAction(
            title: "알림이 오지 않나요?",
            message: "설정으로 이동 후 알림 받기가 꺼져있지는 않은지 확인해 주세요. 그래도 안 되면 어플 재설치를 부탁드립니다."
        ) { selectedOk in
            if selectedOk {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }
        }
    }
}

//MARK: - Target Methods

extension SettingsViewController {
    
    @objc func pressedChangeIdButton() {
        navigationController?.pushViewController(
            ChangeIdViewController(),
            animated: true
        )
    }
    
    @objc func pressedChangeEmailButton() {
        navigationController?.pushViewController(
            ChangeEmailForPasswordLossViewController(),
            animated: true
        )
    }
    
    @objc func pressedUnregisterButton() {
        
        if User.shared.joinedChatRoomPIDs.count != 0 {
            navigationController?.pushViewController(
                UnregisterUser_CheckFirstPrecautionsViewController(),
                animated: true
            )
        } else {
            navigationController?.pushViewController(UnregisterUser_InputPasswordViewController(), animated: true)
        }
    }
}

//MARK: - Initialization

extension SettingsViewController {
    
    private func initialize() {
        initializeLabels()
        initializeButtons()
    }
    
    private func initializeLabels() {
        userIdLabel.text = User.shared.userID
        userNicknameLabel.text = User.shared.nickname
        userEmailLabel.text = User.shared.emailForPasswordLoss
    }
    
    private func initializeButtons() {
        
        changeIdButton.addTarget(
            self,
            action: #selector(pressedChangeIdButton),
            for: .touchUpInside
        )
        changeEmailButton.addTarget(
            self,
            action: #selector(pressedChangeEmailButton),
            for: .touchUpInside
        )
        
        
        unregisterButton.addTarget(
            self,
            action: #selector(pressedUnregisterButton),
            for: .touchUpInside
        )
        
    }
}
