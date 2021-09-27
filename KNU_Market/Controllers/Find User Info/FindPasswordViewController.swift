import UIKit
import PanModal
import TextFieldEffects

protocol FindPasswordDelegate: AnyObject {
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }

    @IBAction func pressedSendEmailButton(_ sender: UIButton) {
        
        guard let email = emailTextField.text else { return }
        
        showProgressBar()
        
        UserManager.shared.findPassword(email: email) { [weak self] result in
            
            dismissProgressBar()
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
              
                self.dismiss(animated: true, completion: nil)
                self.delegate?.didSendFindPasswordEmail()
            
            case .failure(let error):
                self.presentKMAlertOnMainThread(
                    title: "이메일 전송 실패",
                    message: error.errorDescription,
                    buttonTitle: "확인"
                )
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension FindPasswordViewController {
    
    func initialize() {
        initializeSendEmailButton()
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
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(view.bounds.height / 2)
    }
}
