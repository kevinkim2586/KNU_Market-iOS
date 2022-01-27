import UIKit
import SnapKit
import RxSwift
import RxCocoa

class UnregisterUser_CheckSecondPrecautionsViewController: BaseViewController {
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    fileprivate struct Texts {
        static let precautionText = "회원탈퇴를 하실 경우\n\n1. 참가 중인 공구 채팅방 자동으로 나가기\n\n2. 개설한 공구글 자동으로 삭제\n\n위 두 과정이 진행되며,\n\n다시 복구할 수 없음을 알려드립니다."
        
        static let precautionTextToChange = "다시 복구할 수 없음을 알려드립니다."
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(fontSize: 19, textColor: UIColor(named: K.Color.appColor) ?? .systemPink).then {
        $0.text = "회원탈퇴 안내"
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
                self.navigationController?.pushViewController(UnregisterUser_InputPasswordViewController(reactor: UnregisterViewReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)
               
            })
            .disposed(by: disposeBag)
    }
}
