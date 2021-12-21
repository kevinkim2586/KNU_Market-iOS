import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class NickNameInputViewController: BaseViewController, View {
    
    typealias Reactor = NickNameInputViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 20.f
        static let textFieldHeight  = 60.f
    }
    
    //MARK: - UI
    
    let titleLabelFirstLine = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "크누마켓 내에서"
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "크누마켓"
        )
    }
    
    let titleLabelSecondLine = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "사용하실 닉네임을 입력해주세요!"
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "닉네임"
        )
    }
    
    let detailLabel = KMDetailLabel(numberOfTotalLines: 1).then {
        $0.text = "2자 이상, 15자 이하로 적어주세요."
    }
    
    let nicknameTextField = KMTextField(placeHolderText: "닉네임 입력")
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
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
        nicknameTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        nicknameTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        view.addSubview(detailLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabelFirstLine.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        titleLabelSecondLine.snp.makeConstraints {
            $0.top.equalTo(titleLabelFirstLine.snp.bottom).offset(10)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
    
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabelSecondLine.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            $0.height.equalTo(60)
        }
                
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(Metrics.labelSidePadding)
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
    
    func bind(reactor: NickNameInputViewReactor) {
        
        // Input
        
        nicknameTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateTextField($0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .asObservable()
            .map { Reactor.Action.pressedBottomButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidDisappear
            .map { _ in Reactor.Action.viewDidDisappear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.isAllowedToGoNext }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe { _ in
                let vc = EmailForLostPasswordViewController(userManager: UserManager())
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
