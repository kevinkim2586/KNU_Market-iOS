import UIKit
import TextFieldEffects
import Alamofire

class UnregisterUser_InputSuggestionViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var detailLineLabel: UILabel!
    @IBOutlet weak var userInputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
        
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        
        showProgressBar()
        //건의사항 보내기 API 먼저 보내기 실행 (Dispatch Group 으로 해결)
        
        UserManager.shared.unregisterUser { [weak self] result in
            
            dismissProgressBar()
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.popToInitialViewController()
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
}

//MARK: - UI Configuration & Initialization

extension UnregisterUser_InputSuggestionViewController {
    
    func initialize() {
        
        initializeLabels()
        initializeTextView()
    }
    
    func initializeLabels() {
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray

        firstLineLabel.text = "크누마켓팀이 개선했으면\n하는 점을 알려주세요."
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "크누마켓")
        
        detailLineLabel.text = "피드백을 반영하여 적극적으로 개선하겠습니다."
        detailLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detailLineLabel.textColor = .lightGray
    }
    
    func initializeTextView() {
        
        userInputTextView.delegate = self
        userInputTextView.layer.borderWidth = 1.0
        userInputTextView.layer.cornerRadius = 10.0
        userInputTextView.layer.borderColor = UIColor.lightGray.cgColor
        userInputTextView.clipsToBounds = true
        userInputTextView.font = UIFont.systemFont(ofSize: 15)
        userInputTextView.text = "✏️ 개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요."
        userInputTextView.textColor = UIColor.lightGray
    }
}

//MARK: - UITextViewDelegate

extension UnregisterUser_InputSuggestionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "✏️ 개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요."
            textView.textColor = UIColor.lightGray
            return
        }
    }
    
}
