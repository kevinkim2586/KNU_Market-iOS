import UIKit

class CheckEmailViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var fourthLineLabel: UILabel!
    @IBOutlet var detailLabels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }

}

//MARK: - UI Configuration & Initialization

extension CheckEmailViewController {
    
    func initialize() {
        
        initializeLabels()
        initializeTextFields()
    }
    
    func initializeTextFields() {
        
        emailTextField.addTarget(self,
                              action: #selector(textFieldDidChange(_:)),
                              for: .editingChanged)
    }
    
    func initializeLabels() {
        
        errorLabel.isHidden = true
        
        firstLineLabel.text = "마지막으로 학교 이메일 인증을 해주세요!"
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        firstLineLabel.changeTextAttributeColor(fullText: secondLineLabel.text!, changeText: "학교 이메일 인증")
        
        secondLineLabel.text = "크누마켓은 경북대학교 학생들을 위한 공동구매 앱입니다."
        secondLineLabel.changeTextAttributeColor(fullText: secondLineLabel.text!, changeText: "크누마켓")
        thirdLineLabel.text = "앱의 모든 기능을 사용하기 위해서는 반드시 이메일 인증을"
        fourthLineLabel.text = "하셔야 합니다."
        
        detailLabels.forEach { label in
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.textColor = .lightGray
        }
    }

}
