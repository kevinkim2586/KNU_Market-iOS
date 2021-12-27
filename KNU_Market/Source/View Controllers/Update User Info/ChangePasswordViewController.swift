import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ChangePasswordViewController: BaseViewController, View {
    
    typealias Reactor = ChangeUserInfoReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.text = "새 비밀번호를 입력해주세요."
    }
    
    let passwordTextField = KMTextField(placeHolderText: "비밀번호").then {
        $0.isSecureTextEntry = true
    }
    
    let checkPasswordTextField = KMTextField(placeHolderText: "비밀번호 확인").then {
        $0.isSecureTextEntry = true
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
        $0.numberOfLines = 2
    }
    
    let changePasswordButton = KMBottomButton(buttonTitle: "변경하기").then {
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
        title = "비밀번호 변경"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        passwordTextField.inputAccessoryView = changePasswordButton
        checkPasswordTextField.inputAccessoryView = changePasswordButton
        
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(checkPasswordTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        checkPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(checkPasswordTextField.snp.bottom).offset(25)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: ChangeUserInfoReactor) {
        
        // Input
        
        Observable.combineLatest(
            passwordTextField.rx.text.orEmpty,
            checkPasswordTextField.rx.text.orEmpty
        )
            .observe(on: MainScheduler.asyncInstance)
            .map { Reactor.Action.updatePasswordTextFields([$0, $1]) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            passwordTextField.rx.controlEvent([.editingChanged]),
            checkPasswordTextField.rx.controlEvent([.editingChanged])
        )
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .asObservable()
            .map { Reactor.Action.updatePassword }
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
            .map { $0.changeComplete }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
                self.showSimpleBottomAlert(with: "비밀번호 변경에 성공하셨어요.🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}
