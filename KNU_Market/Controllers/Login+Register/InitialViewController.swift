import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
       
    }
    
    //MARK: - IBActions
    
    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
        guard let loginVC = self.storyboard?.instantiateViewController(
                identifier: Constants.StoryboardID.loginVC
        ) as? LoginViewController else {
            return
        }
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func pressedRegisterButton(_ sender: UIButton) {
        
        guard let registerVC = self.storyboard?.instantiateViewController(
                identifier: Constants.StoryboardID.registerVC
        ) as? RegisterViewController else {
            return
        }
        //registerVC.modalPresentationStyle = .fullScreen
        self.present(registerVC, animated: true, completion: nil)
    }
    
    //MARK: - UI Configuration
    
    func initialize() {
        
        initializeLoginButton()
        initializeRegisterButton()
    }
    
    func initializeLoginButton() {

        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
    }
    
    func initializeRegisterButton() {
        
        registerButton.setTitle("회원가입", for: .normal)
        registerButton.setTitleColor(UIColor(named: Constants.Color.appColor), for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        registerButton.addBounceAnimationWithNoFeedback()
        
    }
}

