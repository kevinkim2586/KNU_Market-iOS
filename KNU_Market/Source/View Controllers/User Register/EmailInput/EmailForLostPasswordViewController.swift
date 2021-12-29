import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class EmailForLostPasswordViewController: BaseViewController, View {
    
    typealias Reactor = EmailForLostPasswordViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "비밀번호 분실 시 임시 비밀번호를 받을\n이메일 주소를 입력해주세요!"
        $0.numberOfLines = 2
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "이메일 주소"
        )
    }
    
    let emailTextField = KMTextField(placeHolderText: "이메일 주소 입력").then {
        $0.autocapitalizationType = .none
    }

    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "크누마켓 시작하기").then {
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
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        emailTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(emailTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(54)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(Metrics.labelSidePadding)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    //MARK: - Binding
    
    func bind(reactor: EmailForLostPasswordViewReactor) {
     
        // Input
        
        emailTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateTextField($0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .asObservable()
            .map { Reactor.Action.checkDuplication }
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
            .map { $0.isRegisteredComplete }
            .asObservable()
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { _ in
                self.showCongratulateRegisterVC()
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Registration Method

extension EmailForLostPasswordViewController {

    func showCongratulateRegisterVC() {
        
        let vc = CongratulateUserViewController(
            reactor: CongratulateUserViewReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
