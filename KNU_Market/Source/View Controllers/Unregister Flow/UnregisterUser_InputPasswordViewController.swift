import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class UnregisterUser_InputPasswordViewController: BaseViewController, View {
    
    typealias Reactor = UnregisterViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    fileprivate struct Texts {
        static let titleLabelText          = "회원탈퇴라니요..\n한 번만 더 생각해 주세요.😥"
        static let errorLabelText          = "회원 탈퇴를 위해 비밀번호를 입력해 주세요."
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 2
        $0.text = Texts.titleLabelText
    }
    
    let passwordTextField = KMTextField(placeHolderText: "비밀번호").then {
        $0.isSecureTextEntry = true
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.text = Texts.errorLabelText
        $0.numberOfLines = 2
        $0.isHidden = false
        $0.textColor = .lightGray
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "다음").then {
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        passwordTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setBackBarButtonItemTitle()
    }
    
    //MARK: - Binding
    
    func bind(reactor: UnregisterViewReactor) {
        
        // Input
        
        passwordTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updatePasswordInput($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.text = Texts.errorLabelText
                self.errorLabel.textColor = .lightGray
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .asObservable()
            .map { Reactor.Action.tryLoggingIn }
            .bind(to: reactor.action)
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
                self.errorLabel.showErrorMessage(message: errorMessage!)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.loginCompleted }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.pushViewController(UnregisterUser_InputSuggestionViewController(userManager: UserManager()), animated: true)
            })
            .disposed(by: disposeBag)
    }
}

