import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CheckEmailViewController: BaseViewController {
    
    //MARK: - Properties
    
    var email: String!
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 2
    }
    
    let detailLabel = KMDetailLabel(numberOfTotalLines: 2).then {
        $0.text = "✻ 메일이 보이지 않는 경우 반드시 스팸함을 확인해주세요!"
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "반드시 스팸함을 확인"
        )
    }

    let bottomButton    = KMBottomButton(buttonTitle: "홈으로 돌아가기")
    
    //MARK: - Initialization
    
    init(email: String) {
        super.init()
        self.email = email
        
        titleLabel.text = "\(email)\n위의 메일로 인증 메일이 전송되었습니다."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: email
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "웹메일 인증"
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
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
    
    private func bindUI() {
        
        bottomButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.popVCsFromNavController(count: 3)
            })
            .disposed(by: disposeBag)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct VCPreview: PreviewProvider {
    
    static var previews: some View {
        CheckEmailViewController(email: "kevinkim2586@knu.ac.kr").toPreview()
    }
}
#endif
