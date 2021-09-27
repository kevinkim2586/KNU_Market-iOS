import UIKit

protocol ChooseVerificationOptionDelegate: AnyObject {
    func didSelectToRegister()
}

class ChooseVerificationOptionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var verifiedUsingStudentIdButton: UIButton!
    @IBOutlet weak var verifiedUsingEmailButton: UIButton!
    
    weak var delegate: ChooseVerificationOptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func pressedRegisterButton(_ sender: UIButton) {
        dismiss(animated: true)
        delegate?.didSelectToRegister()
    }
    
    
    @IBAction func pressedVerifiedUsingStudentIdButton(_ sender: UIButton) {
        
    }
    
    
    @IBAction func pressedVerifiedUsingEmailButton(_ sender: UIButton) {
        
    }
    
}

//MARK: - UI Configuration & Initialization

extension ChooseVerificationOptionViewController {
    
    func initialize() {
        title = "아이디 찾기"
        initializeLabels()
        initializeButtons()
    }
    
    func initializeLabels() {
        detailLabel.text = "✻ 인증을 하지 않으신 회원은 아이디 찾기가 불가능합니다."
        detailLabel.changeTextAttributeColor(
            fullText: detailLabel.text!,
            changeText: "인증을 하지 않으신 회원"
        )
    }
    
    func initializeButtons() {
        [verifiedUsingStudentIdButton, verifiedUsingEmailButton].forEach { button in
            button?.layer.cornerRadius = 10
            button?.addBounceAnimationWithNoFeedback()
        }
    }
    
}
