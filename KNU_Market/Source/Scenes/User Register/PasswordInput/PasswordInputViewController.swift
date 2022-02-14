import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class PasswordInputViewController: BaseViewController, View {
    
    typealias Reactor = PasswordInputViewReactor
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 20.f
        static let textFieldHeight  = 60.f
    }
    
    //MARK: - UI
    
    let titleLabelFirstLine = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "\(UserRegisterValues.shared.userId)님 만나서 반갑습니다!"
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "\(UserRegisterValues.shared.userId)님"
        )
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.6
    }
    
    let titleLabelSecondLine = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "사용하실 비밀번호를 입력해 주세요!"
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "비밀번호"
        )
    }
    
    let detailLabel = KMDetailLabel(numberOfTotalLines: 2).then {
        $0.text = ValidationError.OnRegister.incorrectPasswordFormat.rawValue
    }
    
    let passwordTextField = KMTextField(placeHolderText: "비밀번호").then {
        $0.isSecureTextEntry = true
    }
    
    let checkPasswordTextField = KMTextField(placeHolderText: "비밀번호 확인").then {
        $0.isSecureTextEntry = true
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
        checkPasswordTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabelFirstLine)
        view.addSubview(titleLabelSecondLine)
        view.addSubview(detailLabel)
        view.addSubview(passwordTextField)
        view.addSubview(checkPasswordTextField)
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

        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        checkPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Metrics.labelSidePadding)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.labelSidePadding + 130))
            $0.height.equalTo(Metrics.textFieldHeight)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    //MARK: - Binding
    
    func bind(reactor: PasswordInputViewReactor) {
        
        // Input
        
        Observable.combineLatest(
            passwordTextField.rx.text.orEmpty,
            checkPasswordTextField.rx.text.orEmpty
        )
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.updateTextFields([$0, $1]) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            passwordTextField.rx.controlEvent([.editingChanged]),
            checkPasswordTextField.rx.controlEvent([.editingChanged])
        )
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.detailLabel.text = ValidationError.OnRegister.incorrectPasswordFormat.rawValue
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .asObservable()
            .map { Reactor.Action.pressedBottomButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
      
        // Output
            
        reactor.state
            .map { $0.errorMessage }
            .asObservable()
            .bind(to: self.detailLabel.rx.text )
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessageColor }
            .asObservable()
            .bind(to: self.detailLabel.rx.textColor )
            .disposed(by: disposeBag)
    }

}
