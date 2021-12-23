import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Then
import SnapKit

class FindIdUsingStudentIdViewController: BaseViewController, View {
    
    typealias Reactor = FindUserInfoViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let padding = 20.f
    }
    
    //MARK: - UI
    
    let titleLabel = KMTitleLabel(textColor: .darkGray).then {
        $0.numberOfLines = 1
        $0.text = "학번과 생년월일을 입력해주세요."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "학번과 생년월일을 입력"
        )
    }
    
    let userStudentIdTextField = KMTextField(placeHolderText: "학번").then {
        $0.autocapitalizationType = .none
    }
    
    let userBirthDateTextField = KMTextField(placeHolderText: "생년월일 (6자리)").then {
        $0.autocapitalizationType = .none
    }
    
    let errorLabel = KMErrorLabel().then {
        $0.isHidden = true
        $0.numberOfLines = 2
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
        userStudentIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        userStudentIdTextField.inputAccessoryView = bottomButton
        userBirthDateTextField.inputAccessoryView = bottomButton
        
        view.addSubview(titleLabel)
        view.addSubview(userStudentIdTextField)
        view.addSubview(userBirthDateTextField)
        view.addSubview(errorLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
        
        userStudentIdTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(55)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }

        userBirthDateTextField.snp.makeConstraints {
            $0.top.equalTo(userStudentIdTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-(Metrics.padding + 130))
            $0.height.equalTo(60)
        }
    
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(userBirthDateTextField.snp.bottom).offset(Metrics.padding)
            $0.left.equalTo(view.snp.left).offset(Metrics.padding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.padding)
        }
    }

    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }

    //MARK: - Binding
    
    func bind(reactor: FindUserInfoViewReactor) {
        
        // Input
        
        Observable.combineLatest(
            userStudentIdTextField.rx.text.orEmpty,
            userBirthDateTextField.rx.text.orEmpty
        )
            .map { Reactor.Action.updateStudentIdAndStudentBirthDate([$0, $1]) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            userStudentIdTextField.rx.controlEvent([.editingChanged]),
            userBirthDateTextField.rx.controlEvent([.editingChanged])
        )
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
            .map { Reactor.Action.findIdUsingStudentId }
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
