import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ReportUserViewController: BaseViewController, View {
    
    typealias Reactor = ReportUserViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 16.f
    }
    
    fileprivate struct Texts {
        static let detailLabelText: String      = "🥷🏻 사기가 의심되거나 사기를 당하셨나요?\n🤬 부적절한 언어를 사용했나요?\n🤔 아래에 신고 사유를 적어서 보내주세요."
        static let textViewPlaceholder: String  = "신고 내용을 적어주세요. 신고가 접수되면 크누마켓 팀이 검토 후 조치하도록 할게요 :)"
    }
    
    //MARK: - UI
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        $0.textColor = .darkGray
    }
    
    let detailLabel = UILabel().then {
        $0.text = Texts.detailLabelText
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .black
        $0.numberOfLines = 3
        $0.addInterlineSpacing(spacingValue: 10)
    }
    
    let reportTextView = UITextView().then {
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 10.0
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.placeholder = Texts.textViewPlaceholder
    }
    
    let reportButton = UIButton(type: .system).then {
        $0.setTitle("신고 접수", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 5
        $0.addBounceAnimationWithNoFeedback()
    }
    
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
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
    
        UIHelper.addNavigationBarWithDismissButton(in: self.view)
        
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(reportTextView)
        view.addSubview(reportButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        reportTextView.snp.makeConstraints {
            $0.height.equalTo(260)
            $0.top.equalTo(detailLabel.snp.bottom).offset(40)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        reportButton.snp.makeConstraints {
            $0.top.equalTo(reportTextView.snp.bottom).offset(16)
            $0.centerX.equalTo(view.snp.centerX)
            $0.height.equalTo(40)
            $0.width.equalTo(100)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: ReportUserViewReactor) {
        
        // Input
        
        reportTextView.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updateReportContent($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reportButton.rx.tap
            .asObservable()
            .map { Reactor.Action.sendReport }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.userToReport }
            .withUnretained(self)
            .subscribe(onNext: { (_, userToReport) in
                self.titleLabel.text =  "\(userToReport)을(를) 신고하시겠습니까?"
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.isLoading }
            .asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {
                $0 ? showProgressBar() : dismissProgressBar()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, errorMessage) in
                self.view.endEditing(true)
                self.showSimpleBottomAlert(with: errorMessage!)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.reportComplete }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
                self.showSimpleBottomAlert(with: "신고가 정상적으로 접수되었습니다. 감사합니다.😁")
            })
            .disposed(by: disposeBag)
    }
}
