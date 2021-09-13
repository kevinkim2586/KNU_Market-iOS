import UIKit
import Alamofire

class SendDeveloperMessageViewController: UIViewController {
    
    @IBOutlet weak var emailHelpLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    private let emailHelpLabelText = "웹메일 인증과 관련된 문의는 카카오채널을 통해 실시간으로 도와드리겠습니다."
    private let feedbackLabelText = "✻ 건의/제안 사항을 보내주시면 참고하여,\n추후 업데이트에 반영하겠습니다."
    private let textViewPlaceholder = "개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요 😁"
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    
    @IBAction func pressedSendButton(_ sender: UIBarButtonItem) {
        
        guard let content = messageTextView.text else { return }
        
        guard content != textViewPlaceholder else { return }
            
        showProgressBar()
        
        UserManager.shared.sendFeedback(content: content) { [weak self] result in
            
            guard let self = self else { return }
            
            dismissProgressBar()
            
            switch result {
            case .success:
                self.showSimpleBottomAlert(with: "피드백을 성공적으로 보냈습니다. 소중한 의견 감사합니다.😁")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }

    @IBAction func pressedKakaoLink(_ sender: UIButton) {
        
        let url = URL(string: Constants.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
        
    }
    
    func initialize() {
        
        initializeLabels()
        initializeTextView()
    }
    
    func initializeLabels() {
        
        emailHelpLabel.text = emailHelpLabelText
        emailHelpLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emailHelpLabel.textColor = .darkGray
        emailHelpLabel.changeTextAttributeColor(fullText: emailHelpLabelText, changeText: "웹메일 인증과 관련된 문의")
        
        
        feedbackLabel.text = feedbackLabelText
        feedbackLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        feedbackLabel.textColor = .darkGray
    }
    
    func initializeTextView() {
        
        messageTextView.delegate = self
        messageTextView.layer.borderWidth = 1.0
        messageTextView.layer.cornerRadius = 10.0
        messageTextView.layer.borderColor = UIColor.lightGray.cgColor
        messageTextView.clipsToBounds = true
        messageTextView.font = UIFont.systemFont(ofSize: 15)
        messageTextView.text = textViewPlaceholder
        messageTextView.textColor = .lightGray
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
            textView.text = textViewPlaceholder
            textView.textColor = UIColor.lightGray
            return
        }
    }
}
