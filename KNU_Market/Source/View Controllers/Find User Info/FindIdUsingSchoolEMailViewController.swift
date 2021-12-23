import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class FindIdUsingSchoolEMailViewController: BaseViewController, View {
    
    typealias Reactor = FindUserInfoViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 2
        $0.text = "학생 인증에 사용했던\n웹메일 주소를 입력해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "웹메일 주소를 입력"
        )
    }
    
    let userEmailTextField = KMTextField(placeHolderText: "웹메일 아이디 @knu.ac.kr").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
    }
    
    let bottomButton = KMBottomButton(buttonTitle: "아이디 찾기").then {
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
        userEmailTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        userEmailTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(userEmailTextField)
        view.addSubview(errorLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        userEmailTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(userEmailTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    //MARK: - Binding
    
    func bind(reactor: FindUserInfoViewReactor) {
        
        // Input
        
        userEmailTextField.rx.text.orEmpty
            .map { Reactor.Action.updateSchoolEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userEmailTextField.rx.controlEvent([.editingChanged])
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
            .map { Reactor.Action.findIdUsingSchoolEmail }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.foundId }
            .filter { $0 != nil }
            .subscribe(onNext: { foundId in
                self.presentKMAlertOnMainThread(
                    title: "아이디 안내",
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
