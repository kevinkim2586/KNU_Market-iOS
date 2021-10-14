import UIKit

class StudentIDGuideViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        guard let nextVC = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.captureStudentIDVC
        ) as? CaptureStudentIDViewController else { fatalError() }
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

//MARK: - UI Configuration & Initialization

extension StudentIDGuideViewController {
    
    func initialize() {
        title = "모바일 학생증 인증"
        initializeTitleLabel()
        setBackBarButtonItemTitle()
    }
    
    func initializeTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.text = "아래와 같이 학번, 생년월일이 보이게 캡쳐해주세요!"
        titleLabel.textColor = .darkGray
        titleLabel.changeTextAttributeColor(fullText: titleLabel.text!, changeText: "학번, 생년월일이 보이게")

    }
}
