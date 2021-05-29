import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
       
    }

    @IBAction func pressedLoginButton(_ sender: UIButton) {
        
    }
    
    @IBAction func pressedRegisterButton(_ sender: UIButton) {
        
    }
    
    //MARK: - UI Configuration
    
    func initialize() {
        
        initializeLoginButton()
        initializeRegisterButton()
        
        
    }
    
    func initializeLoginButton() {
        
        loginButton.setTitle("로그인", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        loginButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        loginButton.layer.cornerRadius  = 10 //loginButton.frame.height / 2
        loginButton.addBounceAnimationWithNoFeedback()
        
    }
    
    func initializeRegisterButton() {
        
        registerButton.setTitle("회원가입", for: .normal)
        registerButton.setTitleColor(UIColor(named: Constants.Color.appColor), for: .normal)
        registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        registerButton.addBounceAnimationWithNoFeedback()
        
    }
}

