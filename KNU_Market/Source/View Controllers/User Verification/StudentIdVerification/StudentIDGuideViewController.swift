import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class StudentIdGuideViewController: BaseViewController, View {
    
    typealias Reactor = StudentIdGuideReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat = 16
    }

    fileprivate struct Texts {
        static let titleLabel = "아래와 같이 학번, 생년월일이 보이게 캡쳐해주세요!"
    }
    
    //MARK: - UI
    
    let titleLabel = UILabel().then {
        $0.text = Texts.titleLabel
        $0.textColor = .darkGray
        $0.changeTextAttributeColor(fullText: Texts.titleLabel, changeText: "학번, 생년월일이 보이게")
        $0.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.minimumScaleFactor = 0.8
        $0.adjustsFontSizeToFitWidth = true
        $0.numberOfLines = 1
    }
    
    let guideImageView = UIImageView().then {
        $0.image = UIImage(named: K.Images.studentIdGuideImage)
        $0.contentMode = .scaleAspectFit
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "다음")
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackBarButtonItemTitle()
        title = "캡쳐 안내"
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
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(26)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        bottomButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.height.equalTo(bottomButton.heightConstantForKeyboardHidden)
        }
        
        guideImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.bottom.equalTo(bottomButton.snp.top).offset(-25)
        }
    }
    
    func bind(reactor: StudentIdGuideReactor) {
        
        // Input
        
        bottomButton.rx.tap
            .map { Reactor.Action.finishedReadingGuide }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}
