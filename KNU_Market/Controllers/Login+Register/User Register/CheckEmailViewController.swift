import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var fourthLineLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    @IBOutlet var detailLabels: [UILabel]!
    @IBOutlet weak var emailHelpLabel: UILabel!
    @IBOutlet weak var webMailLabel: UILabel!
    
    @IBOutlet weak var verifyUsingStudentIDButton: UIButton!
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
    
    @IBAction func pressedVerifyUsingStudentIDButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            identifier: Constants.StoryboardID.studentIDGuideVC
        ) as? StudentIDGuideViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.congratulateUserVC)
                as? CongratulateUserViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }

    @IBAction func pressedKakaoLinkButton(_ sender: UIButton) {
        
        let url = URL(string: Constants.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
    
}

//MARK: - UI Configuration & Initialization

extension CheckEmailViewController {
    
    func initialize() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification , object: nil)
        
        initializeLabels()
        initializeVerifyUsingStudentIDButton()
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
        
        emailHelpLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        emailHelpLabel.textColor = .darkGray
        
        webMailLabel.text = "웹메일 인증이 어려우시다면\n모바일 학생증으로도 인증 가능합니다."
        webMailLabel.changeTextAttributeColor(fullText: webMailLabel.text!, changeText: "모바일 학생증으로도 인증 가능")
        
    }
    
    func initializeVerifyUsingStudentIDButton() {
        
        verifyUsingStudentIDButton.layer.cornerRadius = 10
        verifyUsingStudentIDButton.addBounceAnimationWithNoFeedback()
    }

}

