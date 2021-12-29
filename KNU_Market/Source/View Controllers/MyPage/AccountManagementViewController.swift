import UIKit
import SnapKit

class AccountManagementViewController: BaseViewController {
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        
        static let labelSidePadding: CGFloat             = 16
        static let stackViewVerticalSpacing: CGFloat     = 24
        static let stackViewSpacing: CGFloat             = 20
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
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 정보 관리"
        label.font = Fonts.titleLabel
        return label
    }()
    
    let idGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디 :"
        label.font = Fonts.userInfoLabel
        label.textColor = Colors.userInfoType
        return label
    }()
    
    let nicknameGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임 :"
        label.font = Fonts.userInfoLabel
        label.textColor = Colors.userInfoType
        return label
    }()
    
    let passwordGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 :"
        label.font = Fonts.userInfoLabel
        label.textColor = Colors.userInfoType
        return label
    }()
    
    let emailGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일 :"
        label.font = Fonts.userInfoLabel
        label.textColor = Colors.userInfoType
        return label
    }()

    let userIdLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.userInfoLabel
        label.text = Texts.labelLoading
        label.textColor = Colors.userInfoLabel
        label.textAlignment = .left
        return label
    }()
    
    let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.userInfoLabel
        label.text = Texts.labelLoading
        label.textColor = Colors.userInfoLabel
        label.textAlignment = .left
        return label
    }()
    
    let userPasswordLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.userInfoLabel
        label.text = Texts.labelLoading
        label.textColor = Colors.userInfoLabel
        label.textAlignment = .left
        return label
    }()
    
    let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.userInfoLabel
        label.text = Texts.labelLoading
        label.textColor = Colors.userInfoLabel
        label.textAlignment = .left
        return label
    }()
    
    // Buttons
    let changeIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Texts.buttonChangeTitle, for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.tag = 0
        button.addTarget(
            self,
            action: #selector(pressedChangedUserInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let changeNicknameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Texts.buttonChangeTitle, for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.tag = 1
        button.addTarget(
            self,
            action: #selector(pressedChangedUserInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Texts.buttonChangeTitle, for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.tag = 2
        button.addTarget(
            self,
            action: #selector(pressedChangedUserInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let changeEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Texts.buttonChangeTitle, for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.tag = 3
        button.addTarget(
            self,
            action: #selector(pressedChangedUserInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let notificationSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("혹시 채팅 알림이 오지 않나요?", for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.setTitleColor(.darkGray, for: .highlighted)
        button.titleLabel?.font = Fonts.button
        button.addTarget(
            self,
            action: #selector(pressedNotificationSettingsButton),
            for: .touchUpInside
        )
        return button
    }()

    let logOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.addTarget(
            self,
            action: #selector(pressedLogOutButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let unregisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원 탈퇴", for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.addTarget(
            self,
            action: #selector(pressedUnregisterButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // StackView
    
    lazy var idStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [idGuideLabel, userIdLabel, changeIdButton].forEach { stackView.addArrangedSubview($0) }
        userIdLabel.text = User.shared.userID
        return stackView
    }()
    
    lazy var nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [nicknameGuideLabel, userNicknameLabel, changeNicknameButton].forEach { stackView.addArrangedSubview($0) }
        userNicknameLabel.text = User.shared.nickname
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
        userEmailLabel.text = User.shared.emailForPasswordLoss
        return stackView
    }()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        idStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        nicknameStackView.snp.makeConstraints { make in
            make.top.equalTo(idStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        passwordStackView.snp.makeConstraints { make in
            make.top.equalTo(nicknameStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        emailStackView.snp.makeConstraints { make in
            make.top.equalTo(passwordStackView.snp.bottom).offset(Metrics.stackViewVerticalSpacing)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        notificationSettingsButton.snp.makeConstraints { make in
            make.top.equalTo(emailStackView.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        unregisterButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        logOutButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(unregisterButton.snp.top).offset(-26)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    private func configure() {
        title = "설정"
    }
}

//MARK: - Actions

extension AccountManagementViewController {

    @objc private func pressedChangedUserInfoButton(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            
            navigationController?.pushViewController(ChangeIdViewController(reactor: ChangeUserInfoReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)

        case 1:
            navigationController?.pushViewController(ChangeNicknameViewController(reactor: ChangeUserInfoReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)
            
            
        case 2:
            
            navigationController?.pushViewController(ChangePasswordViewController(reactor: ChangeUserInfoReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)
    
        case 3:
            
            navigationController?.pushViewController(ChangeEmailForPasswordLossViewController(reactor: ChangeUserInfoReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)
            
        default: break
        }
    }
    
    @objc private func pressedNotificationSettingsButton() {
        presentAlertWithCancelAction(
            title: "알림이 오지 않나요?",
            message: "설정으로 이동 후 알림 받기가 꺼져있지는 않은지 확인해 주세요. 그래도 안 되면 어플 재설치를 부탁드립니다."
        ) { selectedOk in
            if selectedOk {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:],
                    completionHandler: nil
                )
            }
        }
    }
    
    @objc private func pressedLogOutButton() {
        presentAlertWithCancelAction(
            title: "로그아웃 하시겠습니까?",
            message: ""
        ) { selectedOk in
            if selectedOk { DispatchQueue.main.async { self.popToLoginViewController() } }
        }
    }
    
    @objc private func pressedUnregisterButton() {
        if User.shared.joinedChatRoomPIDs.count != 0 {
            navigationController?.pushViewController(
                UnregisterUser_CheckFirstPrecautionsViewController(),
                animated: true
            )
        } else {
            self.navigationController?.pushViewController(UnregisterUser_InputPasswordViewController(reactor: UnregisterViewReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))), animated: true)
    }
}
}
