import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class UnregisterUser_InputSuggestionViewController: BaseViewController, View {
    
    typealias Reactor = UnregisterViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    fileprivate struct Metrics {
        static let padding = 16.f
    }
    
    fileprivate struct Fonts {
        static let titleLabel       = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    fileprivate struct Texts {
        static let titleLabel           = "크누마켓팀이 개선했으면\n하는 점을 알려주세요."
        static let mailGuideLabel       = "웹메일 인증과 관련된 문의는 카카오채널을\n통해 실시간으로 도와드리겠습니다."
        static let textViewPlaceholder  = "✏️ 개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요."
    }
    
    //MARK: - UI
    
    let titleLabel = UILabel().then {
        $0.text = Texts.titleLabel
        $0.font = Fonts.titleLabel
        $0.textColor = .darkGray
        $0.changeTextAttributeColor(fullText: Texts.titleLabel, changeText: "크누마켓")
        $0.numberOfLines = 2
    }
    
    let feedbackLabel = UILabel().then {
        $0.text = "피드백을 반영하여 적극적으로 개선하겠습니다."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .lightGray
    }
    
    let mailGuideLabel = UILabel().then {
        $0.text = Texts.mailGuideLabel
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .darkGray
        $0.changeTextAttributeColor(fullText: Texts.mailGuideLabel, changeText: "웹메일 인증과 관련된 문의")
        $0.numberOfLines = 2
    }
    
    let kakaoChannelLinkButton = UIButton(type: .system).then {
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemBlue
        ]
        let linkString: String = "https://pf.kakao.com/_PjLHs"
        $0.setAttributedTitle(NSAttributedString(string: linkString, attributes: attributes), for: .normal)
    }
    
    let feedbackTextView = UITextView().then {
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 10.0
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.placeholder = Texts.textViewPlaceholder
    }

    let sendFeedbackBarButtonItem = UIBarButtonItem(
        title: "완료",
        style: .done,
        target: nil,
        action: nil
    )
    
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
        
        navigationItem.rightBarButtonItem = sendFeedbackBarButtonItem
        
        view.addSubview(titleLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(mailGuideLabel)
        view.addSubview(kakaoChannelLinkButton)
        view.addSubview(feedbackTextView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
        }
        
        feedbackLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
        }
        
        mailGuideLabel.snp.makeConstraints {
            $0.top.equalTo(feedbackLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
        }
        
        kakaoChannelLinkButton.snp.makeConstraints {
            $0.top.equalTo(mailGuideLabel.snp.bottom).offset(15)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
        }
        
        feedbackTextView.snp.makeConstraints {
            $0.top.equalTo(kakaoChannelLinkButton.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - Binding
    
    func bind(reactor: UnregisterViewReactor) {
        
        // Input
        
        feedbackTextView.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateFeedBackContext($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sendFeedbackBarButtonItem.rx.tap
            .map { Reactor.Action.sendFeedBack }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        kakaoChannelLinkButton.rx.tap
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let url = URL(string: K.URL.kakaoHelpChannel)!
                UIApplication.shared.open(url, options: [:])
            })
            .disposed(by: disposeBag)
        
        // Output
        
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
            .map { $0.alertMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, alertMessage) in
                self.presentCustomAlert(title: "회원 탈퇴 실패", message: alertMessage!)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.unregisterComplete }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.popToLoginViewController()
            })
            .disposed(by: disposeBag)
    }
}


