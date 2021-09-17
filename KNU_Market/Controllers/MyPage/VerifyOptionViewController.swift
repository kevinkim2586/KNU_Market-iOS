import UIKit

class VerifyOptionViewController: UIViewController {
    
    @IBOutlet weak var verifyUsingStudentIDButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    @IBAction func pressedVerifyUsingStudentIDButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VerifyStudentID", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.studentIDGuideVC
        ) as? StudentIDGuideViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedVerifyUsingEmail(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "VerifyEmail", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.emailInputVC
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
