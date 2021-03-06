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
        static let detailLabelText: String      = "๐ฅท๐ป ์ฌ๊ธฐ๊ฐ ์์ฌ๋๊ฑฐ๋ ์ฌ๊ธฐ๋ฅผ ๋นํ์จ๋์?\n๐คฌ ๋ถ์ ์ ํ ์ธ์ด๋ฅผ ์ฌ์ฉํ๋์?\n๐ค ์๋์ ์ ๊ณ  ์ฌ์ ๋ฅผ ์ ์ด์ ๋ณด๋ด์ฃผ์ธ์."
        static let textViewPlaceholder: String  = "์ ๊ณ  ๋ด์ฉ์ ์ ์ด์ฃผ์ธ์. ์ ๊ณ ๊ฐ ์ ์๋๋ฉด ํฌ๋๋ง์ผ ํ์ด ๊ฒํ  ํ ์กฐ์นํ๋๋ก ํ ๊ฒ์ :)"
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
        $0.setTitle("์ ๊ณ  ์ ์", for: .normal)
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
                self.titleLabel.text =  "\(userToReport)์(๋ฅผ) ์ ๊ณ ํ์๊ฒ ์ต๋๊น?"
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
                self.showSimpleBottomAlert(with: "์ ๊ณ ๊ฐ ์ ์์ ์ผ๋ก ์ ์๋์์ต๋๋ค. ๊ฐ์ฌํฉ๋๋ค.๐")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}
