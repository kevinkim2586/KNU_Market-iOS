import UIKit
import Alamofire
import ProgressHUD

class SendDeveloperMessageViewController: UIViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    
    @IBAction func pressedSendButton(_ sender: UIBarButtonItem) {
        
        
        
    }
    
    
    func initialize() {
        
        initializeTextView()
    }
    
    func initializeTextView() {
        
        messageTextView.delegate = self
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.cornerRadius = 10.0
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.clipsToBounds = true
        messageTextView.font = UIFont.systemFont(ofSize: 15)
        messageTextView.text = "개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요 😁"
        messageTextView.textColor = UIColor.lightGray
    }

}

//MARK: - UITextViewDelegate

extension SendDeveloperMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요 😁"
            textView.textColor = UIColor.lightGray
            return
        }
    }
}
