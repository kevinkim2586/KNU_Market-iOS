import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import RxFlow

class UnregisterUser_CheckFirstPrecautionsViewController: BaseViewController, UnregisterViewType, Stepper {
    
    var unregisterStep: UnregisterStepType = .readPrecautionsFirst
    
    var steps = PublishRelay<Step>()
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    fileprivate struct Texts {
        static let precautionText = "현재 참가 중인 공동구매가 존재합니다.\n\n참가 중인 구성원들과 협의를 모두 마친 후 회원 탈퇴를 부탁드립니다.\n\n\n\n협의가 되지 않은 상태에서의 회원탈퇴로 인해 발생하는 문제에 대해서 크누마켓은 책임지지 않습니다."
        
        static let precautionTextToChange = "협의를 모두 마친 후"
    }
    
    //MARK: - UI

    let titleLabel = KMTitleLabel(fontSize: 19, textColor: UIColor(named: K.Color.appColor) ?? .systemPink).then {
        $0.text = "확인하셨나요?"
    }
    
    let detailLabel = KMDetailLabel(fontSize: 16, numberOfTotalLines: 10).then {
        $0.text = Texts.precautionText
        $0.textColor = .darkGray
        $0.changeTextAttributeColor(
            fullText: Texts.precautionText,
            changeText: Texts.precautionTextToChange
        )
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "확인했습니다.").then {
        $0.updateTitleEdgeInsetsForKeyboardHidden()
    }
    
    //MARK: - Initialization
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(bottomButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        bottomButton.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.height.equalTo(bottomButton.heightConstantForKeyboardHidden)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setBackBarButtonItemTitle()
    }

    private func bindUI() {
        
        bottomButton.rx.tap
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.steps.accept(AppStep.readingSecondPrecautionsIsRequired)
            })
            .disposed(by: disposeBag)
    }
}
