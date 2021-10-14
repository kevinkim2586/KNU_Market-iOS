import UIKit
import Alamofire

class SendDeveloperMessageViewController: UIViewController {
    
    @IBOutlet weak var emailHelpLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var timeAvailableLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    private let emailHelpLabelText = "1:1 채팅을 통한 문의를 원하시는 분은 아래 카카오채널로 문의해주세요."
    private let timeAvailableText = "(평일, 주말 09:00 ~ 23:00)"
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
        
        let url = URL(string: K.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
    
    func initialize() {
        initializeLabels()
        initializeTextView()
    }
    
    func initializeLabels() {
        
        [emailHelpLabel, timeAvailableLabel, feedbackLabel].forEach { label in
            label?.font = .systemFont(ofSize: 16, weight: .medium)
            label?.textColor = .darkGray
        }
        
        emailHelpLabel.text = emailHelpLabelText
        emailHelpLabel.changeTextAttributeColor(
            fullText: emailHelpLabelText,
            changeText: "웹메일 인증과 관련된 문의"
        )
        
        timeAvailableLabel.text = timeAvailableText
        feedbackLabel.text = feedbackLabelText
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
