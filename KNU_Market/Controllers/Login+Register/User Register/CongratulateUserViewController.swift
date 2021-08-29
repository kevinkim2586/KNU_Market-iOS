import UIKit
import Lottie

class CongratulateUserViewController: UIViewController {

    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var congratulateLabel: UILabel!
    @IBOutlet weak var goHomeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        playAnimation()
        removeAllPreviousObservers()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.goHomeButton.isHidden = false
            self.goHomeButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func pressedGoHomeButton(_ sender: UIButton) {
        
        showProgressBar()
        
        UserManager.shared.login(email: UserRegisterValues.shared.email,
                                 password: UserRegisterValues.shared.password) { [weak self] result in
            
            guard let self = self else { return }
            
            dismissProgressBar()
            
            switch result {
            case .success:
                self.changeRootViewControllerToMain()
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    @IBAction func pressedSeeTermsAndConditionsButton(_ sender:
                                                        UIButton) {
        let url = URL(string: Constants.URL.termsAndConditionNotionURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    
    @IBAction func pressedSeePrivacyInfoButton(_ sender: UIButton) {
        let url = URL(string: Constants.URL.privacyInfoConditionNotionURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    func initialize() {
        
        initializeButton()
        initializeLabel()
    }
    
    func initializeButton() {
        
        goHomeButton.addBounceAnimationWithNoFeedback()
        goHomeButton.isHidden = true
        goHomeButton.isUserInteractionEnabled = false
        goHomeButton.layer.cornerRadius = goHomeButton.frame.height / 2

    }
    
    func initializeLabel() {
        
        congratulateLabel.text = "크누마켓 회원가입을 축하합니다!"
        congratulateLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        congratulateLabel.textColor = .darkGray
        congratulateLabel.changeTextAttributeColor(fullText: congratulateLabel.text!, changeText: "크누마켓")
    }
    
    func playAnimation() {
        
        animationView.animation = Animation.named("congratulate1")
        
        animationView.backgroundColor = .white
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func changeRootViewControllerToMain() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    func removeAllPreviousObservers() {
        
        NotificationCenter.default.removeObserver(NickNameInputViewController.self)
        NotificationCenter.default.removeObserver(PasswordInputViewController.self)
        NotificationCenter.default.removeObserver(ProfilePictureInputViewController.self)
        NotificationCenter.default.removeObserver(EmailInputViewController.self)
        NotificationCenter.default.removeObserver(CheckEmailViewController.self)
    }
}
