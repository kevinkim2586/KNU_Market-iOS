import UIKit

class VerifyOptionViewController: UIViewController {
    
    @IBOutlet weak var verifyUsingStudentIDButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        if detectIfVerifiedUser() {
            presentKMAlertOnMainThread(
                title: "인증 회원 안내",
                message: "이미 인증된 회원입니다.\n이제 공동구매를 즐겨보세요!",
                buttonTitle: "확인"
            )
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func pressedVerifyUsingStudentIDButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardName.VerifyStudent, bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            identifier: K.StoryboardID.studentIDGuideVC
        ) as? StudentIDGuideViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedVerifyUsingEmail(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardName.VerifyEmail, bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            identifier: K.StoryboardID.emailInputVC
        ) as? EmailInputViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configure() {
        title = "학생 인증하기"
        setBackBarButtonItemTitle()
        configureButtons()
    }
    
    private func configureButtons() {
        [verifyUsingStudentIDButton, resendEmailButton].forEach { button in
            button?.layer.cornerRadius = 10
            button?.addBounceAnimationWithNoFeedback()
        }
    }
}
