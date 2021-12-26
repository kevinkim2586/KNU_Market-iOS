import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class EmailVerificationViewController: BaseViewController, View {
    
    typealias Reactor = EmailVerificationViewReactor
    
    //MARK: - Properties

    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "웹메일(@knu.ac.kr)을 입력해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "웹메일(@knu.ac.kr)을 입력"
        )
    }
    let detailLabelFirstLine = KMDetailLabel(numberOfTotalLines: 2).then {
        $0.text = "✻ 메일이 보이지 않는 경우 반드시 스팸 메일함을\n확인해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "반드시 스팸 메일함을\n확인"
        )
    }
    
    let detailLabelSecondLine = KMDetailLabel(numberOfTotalLines: 1).then {
        $0.text = "✻ 웹메일 ID는 yes 포털 아이디와 동일합니다."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "yes 포털 아이디와 동일"
        )
    }
    
    let emailTextField = KMTextField(placeHolderText: "웹메일 아이디 @knu.ac.kr").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
        $0.numberOfLines = 3
    }
    let bottomButton = KMBottomButton(buttonTitle: "인증 메일 보내기").then {
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
        title = "웹메일 인증"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        emailTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(detailLabelFirstLine)
        view.addSubview(detailLabelSecondLine)
        view.addSubview(emailTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        detailLabelFirstLine.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        detailLabelSecondLine.snp.makeConstraints {
            $0.top.equalTo(detailLabelFirstLine.snp.bottom).offset(15)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(detailLabelSecondLine.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 100))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    //MARK: - Binding
    
    func bind(reactor: EmailVerificationViewReactor) {
        
        // Input
        
        emailTextField.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updateTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .flatMap { [unowned self] in
                self.presentAlertWithConfirmation(title: "인증 메일을 보내시겠습니까?", message: nil)
            }
            .map { actionType -> Reactor.Action in
                switch actionType {
                case .ok: return Reactor.Action.sendVerificationEmail
                case .cancel: return Reactor.Action.dismiss
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output

        emailTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
                self.errorLabel.text = nil
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
            .map { ($0.isAllowedToGoNext, $0.email) }
            .distinctUntilChanged { $0.0 }
            .filter { $0.0 == true }
            .subscribe(onNext: {
                let vc = CheckYourEmailViewController(email: $0.1)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
     
        reactor.state
            .map { $0.errorMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, errorMessage) in
                self.errorLabel.showErrorMessage(message: errorMessage!)
            }
            .disposed(by: disposeBag)
    }
}


