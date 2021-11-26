import UIKit
import SnapKit

class StudentIdGuideViewController: BaseViewController {
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat = 16
    }

    fileprivate struct Texts {
        static let titleLabel = "아래와 같이 학번, 생년월일이 보이게 캡쳐해주세요!"
    }
    
    //MARK: - UI
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.titleLabel
        label.textColor = .darkGray
        label.changeTextAttributeColor(fullText: Texts.titleLabel, changeText: "학번, 생년월일이 보이게")
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    let guideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.studentIdGuideImage)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let bottomButton: KMBottomButton = {
        let button = KMBottomButton(buttonTitle: "다음")
        button.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside)
        return button
    }()
    
    //MARK: - Initialization
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabel)
        view.addSubview(guideImageView)
        view.addSubview(bottomButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        bottomButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(bottomButton.heightConstantForKeyboardHidden)
        }
        
        guideImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.bottom.equalTo(bottomButton.snp.top).offset(-25)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    override func setupActions() {
        super.setupActions()
    }
    
    private func configure() {
        setBackBarButtonItemTitle()
        title = "캡쳐 안내"
    }
}

//MARK: - Target Methods

extension StudentIdGuideViewController {
    
    @objc private func pressedBottomButton() {        
        navigationController?.pushViewController(CaptureStudentIdViewController(userManager: UserManager()), animated: true)
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct StudentIdGuideVC: PreviewProvider {
    
    static var previews: some View {
        StudentIdGuideViewController().toPreview()
    }
}
#endif
