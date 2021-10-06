import UIKit

class VerifyEmailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    @IBOutlet weak var emailGuideLabel: UILabel!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    @IBAction func pressedKakaoLinkLabel(_ sender: UIButton) {
        let url = URL(string: Constants.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
    
    @IBAction func pressedResendEmailButton(_ sender: UIButton) {
        
//        presentAlertWithCancelAction(
//            title: "인증 메일을 다시 보내시겠습니까?",
//            message: ""
//        ) { selectedOk in
//            if selectedOk {
//                showProgressBar()
//                UserManager.shared.sendVerificationEmail(){ [weak self] result in
//
//                    dismissProgressBar()
//
//                    guard let self = self else { return }
//
//                    switch result {
//
//                    case .success:
//                        self.showSimpleBottomAlert(with: "인증 메일 보내기 성공 🎉 메일함을 확인해 주세요!")
//
//                    case .failure(let error):
//                        self.showSimpleBottomAlert(with: error.errorDescription)
//                    }
//                }
//            }
//        }
//
    }
    
}

//MARK: - Initialization & UI Configuration

extension VerifyEmailViewController {
    
    func initialize() {
        
        initializeLabels()
        initializeResendEmailButton()
        addDismissButtonToRightNavBar()
    }
    
    func initializeLabels() {
        
        detailLabel.text = "\(User.shared.email)로 발송된 인증 메일을 확인해주세요. 이메일의 인증 버튼을 누르면 인증이 완료됩니다."
        
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.changeTextAttributeColor(fullText: detailLabel.text!, changeText: User.shared.email)
        
        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 스팸 메일함을 확인해주세요!"
        checkSpamMailLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        checkSpamMailLabel.textColor = .darkGray
        checkSpamMailLabel.changeTextAttributeColor(
            fullText: checkSpamMailLabel.text!,
            changeText: "스팸 메일함"
        )
        
        emailGuideLabel.text = "웹메일 인증과 관련된 문의는 카카오채널을\n통해 실시간으로 도와드리겠습니다."
        emailGuideLabel.font = .systemFont(ofSize: 14, weight: .medium)
        emailGuideLabel.textColor = .darkGray
        
    }
    
    func initializeResendEmailButton() {
        
        resendEmailButton.layer.cornerRadius = resendEmailButton.frame.height / 2
        resendEmailButton.addBounceAnimationWithNoFeedback()
    }
}
