import UIKit
import PanModal
import TextFieldEffects

protocol FindPasswordDelegate: AnyObject{
    
    func didSendFindPasswordEmail()
}

class FindPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    weak var delegate: FindPasswordDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()
    }

    @IBAction func pressedSendEmailButton(_ sender: UIButton) {
        
        guard let email = emailTextField.text else { return }
        
        UserManager.shared.findPassword(email: email) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
              
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didSendFindPasswordEmail()
            
            case .failure(let error):
                self.presentSimpleAlert(title: "이메일 전송 실패", message: error.errorDescription)
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension FindPasswordViewController {
    
    func initialize() {
        
        initializeDetailLabel()
        initializeSendEmailButton()
        
    }
    
    func initializeDetailLabel() {
        
    }
    
    func initializeSendEmailButton() {
        
        sendEmailButton.layer.cornerRadius = sendEmailButton.frame.height / 2
        sendEmailButton.addBounceAnimationWithNoFeedback()
        sendEmailButton.backgroundColor = UIColor(named: Constants.Color.appColor)
    }
}

//MARK: - PanModalPresentable

extension FindPasswordViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(view.bounds.height / 2)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(50)
    }
}
