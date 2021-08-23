import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var fourthLineLabel: UILabel!
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
        
        firstLineLabel.text = "\(UserRegisterValues.shared.email)로 발송된\n이메일을 확인해 주세요!"
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "\(UserRegisterValues.shared.email)")
        
        secondLineLabel.text = "발송된 메일 내의 링크를 클릭해야지만 이메일 인증이"
        thirdLineLabel.text = "최종적으로 완료가 됩니다."
        fourthLineLabel.text = "인증을 하지 않으면 일부 기능이 제한될 수 있습니다."
    
        detailLabels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .lightGray
        }
    }

}
