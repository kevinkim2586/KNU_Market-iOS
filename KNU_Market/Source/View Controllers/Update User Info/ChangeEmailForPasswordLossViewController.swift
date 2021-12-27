import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ChangeEmailForPasswordLossViewController: BaseViewController, View {
    
    typealias Reactor = ChangeUserInfoReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(fontSize: 17, textColor: .darkGray).then {
        $0.numberOfLines = 5
        $0.text = "새로운 이메일 주소를 입력해주세요.\n\n비밀번호 분실 시, 해당 이메일 주소로 임시 비밀번호가 전송되니, 이메일 변경은 신중히 부탁드립니다."
    }
    
    let emailTextField = KMTextField(placeHolderText: "변경하실 이메일 입력")
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
    }
    
    let changeEmailButton = KMBottomButton(buttonTitle: "변경하기").then {
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
        title = "이메일 변경"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        emailTextField.inputAccessoryView = changeEmailButton
        
        view.addSubview(titleLabel)
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
        
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(Metrics.padding)
        }
        
    }
    
    //MARK: - Binding
    
    func bind(reactor: ChangeUserInfoReactor) {
        
        // Input
        
        emailTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateEmailTextField($0) }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        emailTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        changeEmailButton.rx.tap
            .asObservable()
            .map { Reactor.Action.updateUserInfo(.email, .email) }
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
                self.emailTextField.resignFirstResponder()
                self.showSimpleBottomAlert(with: "이메일이 변경되었어요.🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

