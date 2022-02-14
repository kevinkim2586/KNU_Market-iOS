import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class AccountManagementViewController: BaseViewController, View {
    
    typealias Reactor = AccountManagementViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding         = 16.f
        static let stackViewVerticalSpacing = 24.f
        static let stackViewSpacing         = 20.f
    }
    
    fileprivate struct Fonts {
        static let titleLabel       = UIFont.systemFont(ofSize: 19, weight: .semibold)
        static let userInfoLabel    = UIFont.systemFont(ofSize: 16)
        static let button           = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }
    
    fileprivate struct Colors {
        
        static let userInfoType     = UIColor.black
        static let userInfoLabel    = UIColor.darkGray
        static let button           = UIColor(named: K.Color.appColor)
    }
    
    fileprivate struct Texts {
        static let labelLoading          = "로딩 중.."
        static let buttonChangeTitle     = "변경"
    }
    
    //MARK: - UI
    
    // Labels
    let titleLabel = UILabel().then {
        $0.text = "계정 정보 관리"
        $0.font = Fonts.titleLabel
    }
    
    let idGuideLabel = UILabel().then {
        $0.text = "아이디 :"
        $0.font = Fonts.userInfoLabel
        $0.textColor = Colors.userInfoType
    }
    
    let nicknameGuideLabel = UILabel().then {
        $0.text = "닉네임 :"
        $0.font = Fonts.userInfoLabel
        $0.textColor = Colors.userInfoType
    }
    
    let passwordGuideLabel = UILabel().then {
        $0.text = "비밀번호 :"
        $0.font = Fonts.userInfoLabel
        $0.textColor = Colors.userInfoType
    }
    
    let emailGuideLabel = UILabel().then {
        $0.text = "이메일 :"
        $0.font = Fonts.userInfoLabel
        $0.textColor = Colors.userInfoType
    }
    
    let userIdLabel = UILabel().then {
        $0.font = Fonts.userInfoLabel
        $0.text = Texts.labelLoading
        $0.textColor = Colors.userInfoLabel
        $0.textAlignment = .left
    }
    
    let userNicknameLabel = UILabel().then {
        $0.font = Fonts.userInfoLabel
        $0.text = Texts.labelLoading
        $0.textColor = Colors.userInfoLabel
        $0.textAlignment = .left
    }
    
    let userPasswordLabel = UILabel().then {
        $0.font = Fonts.userInfoLabel
        $0.text = Texts.labelLoading
        $0.textColor = Colors.userInfoLabel
        $0.textAlignment = .left
    }
    
    let userEmailLabel = UILabel().then {
        $0.font = Fonts.userInfoLabel
        $0.text = Texts.labelLoading
        $0.textColor = Colors.userInfoLabel
        $0.textAlignment = .left
    }
    
    // Buttons
    let changeIdButton = UIButton(type: .system).then {
        $0.setTitle(Texts.buttonChangeTitle, for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    let changeNicknameButton = UIButton(type: .system).then {
        $0.setTitle(Texts.buttonChangeTitle, for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    let changePasswordButton = UIButton(type: .system).then {
        $0.setTitle(Texts.buttonChangeTitle, for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    let changeEmailButton = UIButton(type: .system).then {
        $0.setTitle(Texts.buttonChangeTitle, for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    let notificationSettingsButton = UIButton(type: .system).then {
        $0.setTitle("혹시 채팅 알림이 오지 않나요?", for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.setTitleColor(.darkGray, for: .highlighted)
        $0.titleLabel?.font = Fonts.button
    }
    
    let logOutButton = UIButton(type: .system).then {
        $0.setTitle("로그아웃", for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    let unregisterButton = UIButton(type: .system).then {
        $0.setTitle("회원 탈퇴", for: .normal)
        $0.setTitleColor(Colors.button, for: .normal)
        $0.titleLabel?.font = Fonts.button
    }
    
    // StackView
    
    lazy var idStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [idGuideLabel, userIdLabel, changeIdButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    lazy var nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [nicknameGuideLabel, userNicknameLabel, changeNicknameButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    lazy var passwordStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [passwordGuideLabel, userPasswordLabel, changePasswordButton].forEach { stackView.addArrangedSubview($0) }
        userPasswordLabel.text = "************"
        return stackView
    }()
    
    lazy var emailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [emailGuideLabel, userEmailLabel, changeEmailButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    //MARK: - Init
    
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
        title = "설정"
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(titleLabel)
        view.addSubview(idStackView)
        view.addSubview(nicknameStackView)
        view.addSubview(passwordStackView)
        view.addSubview(emailStackView)
        view.addSubview(notificationSettingsButton)
        view.addSubview(logOutButton)
        view.addSubview(unregisterButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        idStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        nicknameStackView.snp.makeConstraints {
            $0.top.equalTo(idStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        passwordStackView.snp.makeConstraints {
            $0.top.equalTo(nicknameStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        emailStackView.snp.makeConstraints {
            $0.top.equalTo(passwordStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        notificationSettingsButton.snp.makeConstraints {
            $0.top.equalTo(emailStackView.snp.bottom).offset(50)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        unregisterButton.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        logOutButton.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.bottom.equalTo(unregisterButton.snp.top).offset(-26)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: AccountManagementViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .asObservable()
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidAppear
            .asObservable()
            .map { _ in Reactor.Action.viewDidAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeIdButton.rx.tap
            .map { Reactor.Action.changeId }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeNicknameButton.rx.tap
            .map { Reactor.Action.changeNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changePasswordButton.rx.tap
            .map { Reactor.Action.changePassword }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        changeEmailButton.rx.tap
            .map { Reactor.Action.changeEmailForPasswordLoss }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        logOutButton.rx.tap
            .flatMap { [unowned self] in
                self.presentAlertWithConfirmation(
                    title: "로그아웃 하시겠습니까?",
                    message: ""
                )
            }
            .subscribe(onNext: { [weak self] actionType in
                switch actionType {
                case .ok:
                    self?.reactor?.action.onNext(.logout)
                default: break
                }
            })
            .disposed(by: disposeBag)
        
           notificationSettingsButton.rx.tap
               .flatMap { [unowned self] in
                   self.presentAlertWithConfirmation(
                       title: "알림이 오지 않나요?",
                       message: "설정으로 이동 후 알림 받기가 꺼져있지는 않은지 확인해 주세요. 그래도 안 되면 어플 재설치를 부탁드립니다."
                   )
               }
               .subscribe(onNext: { actionType in
                   switch actionType {
                   case .ok:
                       self.reactor?.action.onNext(.openSystemSettingsApp)
                   default: break
                   }
               })
               .disposed(by: disposeBag)
        
        unregisterButton.rx.tap
            .map { Reactor.Action.unregister }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.userId }
            .bind(to: userIdLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userNickname }
            .bind(to: userNicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userEmailForPasswordLoss }
            .bind(to: userEmailLabel.rx.text)
            .disposed(by: disposeBag)
        
        
    }
}
