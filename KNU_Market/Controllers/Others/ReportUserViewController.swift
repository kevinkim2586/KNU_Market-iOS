import UIKit
import SnackBar_swift
import ProgressHUD

class ReportUserViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    var userToReport: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedSendButton(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        showProgressBar()
        
        let model = ReportUserRequestDTO(user: userToReport,
                                    content: contentTextView.text!)
        
        print("userToReport: \(userToReport)")
        
        ReportManager.shared.reportUser(with: model) { result in
            
            dismissProgressBar()
            
            switch result {
            
            case .success(_):
                
                self.showSimpleBottomAlert(with: "신고가 정상적으로 접수되었습니다. 감사합니다 😁")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    self.dismiss(animated: true)
                }
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }

}


//MARK: - Initialization

extension ReportUserViewController {
    
    func initialize() {
        
        initializeTitleLabel()
        initializeTextView()
        initializeButton()
        initializeNavigationBar()
    }
    
    func initializeTitleLabel() {
        
        titleLabel.text = "\(userToReport)를 신고하시겠습니까?"
        
    }
    
    func initializeTextView() {
        
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 10.0
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.clipsToBounds = true
        contentTextView.font = UIFont.systemFont(ofSize: 15)
        contentTextView.text = "신고 내용을 적어주세요❗️"
        contentTextView.textColor = UIColor.lightGray
    }
    
    func initializeButton() {
        sendButton.layer.cornerRadius = 10
    }
    
    func initializeNavigationBar() {
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 150
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight,
                                                          width: view.bounds.size.width, height: 50))
        navigationBar.tintColor = .lightGray
        navigationBar.setBackgroundImage(UIImage(),
                                         for: .default)
        navigationBar.shadowImage = UIImage()
        self.view.addSubview(navigationBar)
        
        let navItem = UINavigationItem(title: "")
        let navBarButton = UIBarButtonItem(barButtonSystemItem: .close,
                                           target: self,
                                           action: #selector(dismissVC))
        navItem.leftBarButtonItem = navBarButton
        navigationBar.items = [navItem]
    }
}

//MARK: - Input Validation

extension ReportUserViewController {
    
    func validateUserInput() -> Bool {
        
        guard contentTextView.text != "신고 내용을 적어주세요❗️" else {
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
            
            textView.text = "신고 내용을 적어주세요❗️"
            textView.textColor = UIColor.lightGray
            return
        }
    }
}
