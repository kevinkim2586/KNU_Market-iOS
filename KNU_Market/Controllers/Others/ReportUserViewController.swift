import UIKit

class ReportUserViewController: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    var userToReport: String = ""
    var postUID: String = ""
    
    private let textViewPlaceholder: String = "신고 내용을 적어주세요❗️"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func pressedSendButton(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        showProgressBar()
        
        let model = ReportUserRequestDTO(user: userToReport,
                                         content: contentTextView.text!,
                                         postUID: postUID)
        
        ReportManager.shared.reportUser(with: model) { result in

            dismissProgressBar()

            switch result {

            case .success(_):

                self.showSimpleBottomAlert(with: "신고가 정상적으로 접수되었습니다. 감사합니다.😁")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }

            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }

}


//MARK: - Input Validation

extension ReportUserViewController {
    
    func validateUserInput() -> Bool {
        guard contentTextView.text != textViewPlaceholder else {
            self.showSimpleBottomAlert(with: "신고 내용을 3글자 이상 적어주세요 👀")
            return false
        }
        guard let content = contentTextView.text else { return false }
        
        if content.count >= 3 { return true }
        else {
            self.showSimpleBottomAlert(with: "신고 내용을 3글자 이상 적어주세요 👀")
            return false
        }
    }
}

//MARK: - UITextViewDelegate

extension ReportUserViewController: UITextViewDelegate {
    
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

//MARK: - Initialization & UI Configuration

extension ReportUserViewController {
    
    func initialize() {
        initializeDismissButton()
        initializeTitleLabel()
        initializeTextView()
        initializeButton()
    }
    
    func initializeDismissButton() {
        dismissButton.setTitle("", for: .normal)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .darkGray
    }
    
    func initializeTitleLabel() {
        titleLabel.text = "\(userToReport)를 신고하시겠습니까?"
    }
    
    func initializeTextView() {
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 0.7
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.clipsToBounds = true
        contentTextView.font = UIFont.systemFont(ofSize: 15)
        contentTextView.text = textViewPlaceholder
        contentTextView.textColor = UIColor.lightGray
    }
    
    func initializeButton() {
        sendButton.layer.cornerRadius = 5
    }
}
