import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var fourthLineLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    @IBOutlet weak var checkAfterSomeTimeLabel: UILabel!
    @IBOutlet var detailLabels: [UILabel]!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            nextButtonBottomAnchor.constant = keyboardSize.height
            nextButtonHeight.constant = 60
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        nextButtonBottomAnchor.constant = 0
        nextButtonHeight.constant = 80
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.congratulateUserVC)
                as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }

}

//MARK: - UI Configuration & Initialization

extension CheckEmailViewController {
    
    func initialize() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification , object: nil)
        
        initializeLabels()
    }
    
    func initializeLabels() {
        
        firstLineLabel.text = "\(UserRegisterValues.shared.email)\n위의 메일로 인증 메일이 전송되었습니다."
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "\(UserRegisterValues.shared.email)")

        fourthLineLabel.text = "인증을 하지 않아도 가입은 되지만, 일부 기능이 제한될 수 있습니다."
    
        detailLabels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .lightGray
        }
        
        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 스팸 메일함을 확인해주세요!"
        checkSpamMailLabel.textColor = UIColor(named: Constants.Color.appColor)
        
        checkAfterSomeTimeLabel.text = "✻ 인증 메일 전송이 최대 3시간 이상 지연되는 문제가 있을 수 있습니다. 미리 양해 부탁드리겠습니다.😢"
        checkAfterSomeTimeLabel.textColor = UIColor(named: Constants.Color.appColor)
    }

}

