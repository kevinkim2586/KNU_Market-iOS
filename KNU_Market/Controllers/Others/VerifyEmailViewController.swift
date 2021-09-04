import UIKit

class VerifyEmailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    

    @IBAction func pressedResendEmailButton(_ sender: UIButton) {
        
        showProgressBar()
        UserManager.shared.resendVerificationEmail { [weak self] result in
            
            dismissProgressBar()
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.showSimpleBottomAlert(with: "인증 메일 보내기 성공 🎉 메일함을 확인해 주세요!")
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
}

//MARK: - Initialization & UI Configuration

extension VerifyEmailViewController {
    
    func initialize() {
        
        initializeDetailLabel()
        initializeResendEmailButton()
        addDismissButtonToRightNavBar()
    }
    
    func initializeDetailLabel() {
        
        detailLabel.text = "\(User.shared.email)로 발송된 인증 메일을 확인해주세요. 이메일의 인증 버튼을 누르면 인증이 완료됩니다."
        
        detailLabel.adjustsFontSizeToFitWidth = true
        detailLabel.changeTextAttributeColor(fullText: detailLabel.text!, changeText: User.shared.email)
        
        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 스팸 메일함을 확인해주세요!"
        checkSpamMailLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        checkSpamMailLabel.textColor = .lightGray
    }
    
    func initializeResendEmailButton() {
        
        resendEmailButton.layer.cornerRadius = resendEmailButton.frame.height / 2
        resendEmailButton.addBounceAnimationWithNoFeedback()
    }
}
