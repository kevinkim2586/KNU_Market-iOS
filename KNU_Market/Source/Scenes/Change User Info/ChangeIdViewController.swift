import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class ChangeIdViewController: BaseViewController, View {
    
    typealias Reactor = ChangeUserInfoReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(fontSize: 18, textColor: .darkGray).then {
        $0.text = "새로운 아이디를 입력해주세요."
    }
    
    let idTextField = KMTextField(placeHolderText: "새 아이디 입력").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
    }
    
    let changeIdButton = KMBottomButton(buttonTitle: "변경하기").then {
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
        title = "아이디 변경"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        idTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        idTextField.inputAccessoryView = changeIdButton
        
        view.addSubview(titleLabel)
        view.addSubview(idTextField)
        view.addSubview(errorLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        idTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(idTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(Metrics.padding)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: ChangeUserInfoReactor) {
        
        // Input
        
        idTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateIdTextField($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        idTextField.rx.controlEvent([.editingChanged])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.errorLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        
        changeIdButton.rx.tap
            .asObservable()
            .map { Reactor.Action.updateUserInfo(.id, .username)}
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
                self.view.endEditing(true)
                self.errorLabel.showErrorMessage(message: errorMessage!)
            }
            .disposed(by: disposeBag)
    
        reactor.state
            .map { $0.changeComplete }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.idTextField.resignFirstResponder()
                self.showSimpleBottomAlert(with: "아이디가 성공적으로 변경됐어요.🎉")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}


