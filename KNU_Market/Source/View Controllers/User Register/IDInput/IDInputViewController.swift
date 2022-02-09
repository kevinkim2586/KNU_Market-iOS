import UIKit
import TextFieldEffects
import SnapKit
import ReactorKit

class IDInputViewController: BaseViewController, View {
    
    typealias Reactor = IDInputViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 16.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 2
        $0.text = "환영합니다, 학우님!\n로그인에 사용할 아이디를 입력해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "로그인에 사용할 아이디"
        )
    }
    
    let userIdTextField = KMTextField(placeHolderText: "아이디 입력").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
        $0.numberOfLines = 2
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "다음").then {
        $0.heightAnchor.constraint(equalToConstant: $0.heightConstantForKeyboardAppeared).isActive = true
    }
    
    let dismissBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "xmark"),
        style: .plain,
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = dismissBarButtonItem
        userIdTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(userIdTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        userIdTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(userIdTextField.snp.bottom).offset(Metrics.labelSidePadding)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
        setClearNavigationBarBackground()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    //MARK: - Binding
    
    func bind(reactor: IDInputViewReactor) {
        
        // Input
        
        dismissBarButtonItem.rx.tap
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dismissVC()
            })
            .disposed(by: disposeBag)
        
        userIdTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateTextField($0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        userIdTextField.rx.controlEvent([.editingDidBegin, .editingChanged])
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
            .map { $0.errorMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, errorMessage) in
                self.errorLabel.showErrorMessage(message: errorMessage!)
            }
            .disposed(by: disposeBag)
    }
}

