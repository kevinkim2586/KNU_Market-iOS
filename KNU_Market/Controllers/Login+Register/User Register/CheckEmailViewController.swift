import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var checkSpamMailLabel: UILabel!
 
    @IBOutlet weak var goBackToHomeButton: UIButton!
    @IBOutlet weak var goBackToHomeButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var goBackToHomeButtonHeight: NSLayoutConstraint!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            goBackToHomeButtonBottomAnchor.constant = keyboardSize.height
            goBackToHomeButtonHeight.constant = 60
            goBackToHomeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        goBackToHomeButtonBottomAnchor.constant = 0
        goBackToHomeButtonHeight.constant = 80
    }
    
    @IBAction func pressedVerifyUsingStudentIDButton(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(
            identifier: Constants.StoryboardID.studentIDGuideVC
        ) as? StudentIDGuideViewController else { return }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pressedGoBackToHomeButton(_ sender: UIButton) {
        popVCs(count: 3)
    }

    @IBAction func pressedKakaoLinkButton(_ sender: UIButton) {
        let url = URL(string: Constants.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
    
}

//MARK: - UI Configuration & Initialization

extension CheckEmailViewController {
    
    func initialize() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name:UIResponder.keyboardWillHideNotification ,
            object: nil
        )
        
        title = "웹메일 인증"
        
        initializeLabels()

    }
    
    func initializeLabels() {
        
        guard let email = email else { return }
        
        firstLineLabel.text = "\(email)\n위의 메일로 인증 메일이 전송되었습니다."
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.changeTextAttributeColor(
            fullText: firstLineLabel.text!,
            changeText: "\(email)"
        )

        checkSpamMailLabel.text = "✻ 메일이 보이지 않는 경우 반드시 스팸 메일함을 확인해주세요!"
        checkSpamMailLabel.textColor = UIColor(named: Constants.Color.appColor)
        checkSpamMailLabel.changeTextAttributeColor(
            fullText: checkSpamMailLabel.text!,
            changeText: "반드시 스팸 메일함을 확인"
        )
        
    
        
    }

}

