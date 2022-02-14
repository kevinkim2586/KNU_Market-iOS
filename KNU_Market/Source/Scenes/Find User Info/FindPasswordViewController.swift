import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class FindPasswordViewController: BaseViewController, View {
    
    typealias Reactor = FindUserInfoViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 1
        $0.text = "크누마켓 아이디를 입력해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "크누마켓 아이디"
        )
    }
    
    let detailLabel = KMDetailLabel(numberOfTotalLines: 2).then {
        $0.numberOfLines = 2
        $0.text = "회원가입 시 입력했던 이메일로\n임시 비밀번호가 전송됩니다."
    }
    
    let userIdTextField = KMTextField(placeHolderText: "크누마켓 아이디").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "임시 비밀번호 받기").then {
        $0.heightAnchor.constraint(equalToConstant: $0.heightConstantForKeyboardAppeared).isActive = true
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
        title = "비밀번호 찾기"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        userIdTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(userIdTextField)
        view.addSubview(errorLabel)
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
            $0.right.equalTo(view.snp.right).offset(Metrics.padding)
        }

        userIdTextField.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(userIdTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setClearNavigationBarBackground()
    }
    
    //MARK: - Binding
    
    func bind(reactor: FindUserInfoViewReactor) {
        
        // Input
        
        userIdTextField.rx.text.orEmpty
            .map { Reactor.Action.updateId($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userIdTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
                self.errorLabel.text = nil
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .asObservable()
            .map { Reactor.Action.findPassword }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.emailNewPasswordSent }
            .filter { $0 != nil }
            .subscribe(onNext: { foundId in
                self.presentKMAlertOnMainThread(
                    title: "비밀번호 안내",
                    message: "",
                    buttonTitle: "닫기",
                    attributedMessageString: foundId
                )
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
            .subscribe(onNext: { (_, errorMessage) in
                self.errorLabel.showErrorMessage(message: errorMessage!)
            })
            .disposed(by: disposeBag)
    }
}
