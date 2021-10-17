import UIKit
import SnapKit

class AccountManagementViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var user: User?
    
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
        let button = UIButton()
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
        let button = UIButton()
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
        let button = UIButton()
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
        let button = UIButton()
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
        let button = UIButton()
        button.setTitle("혹시 채팅 알림이 오지 않나요?", for: .normal)
        button.setTitleColor(Colors.button, for: .normal)
        button.titleLabel?.font = Fonts.button
        button.addTarget(
            self,
            action: #selector(pressedNotificationSettingsButton),
            for: .touchUpInside
        )
        return button
    }()

    let logOutButton: UIButton = {
        let button = UIButton()
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
        let button = UIButton()
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
        userIdLabel.text = self.user?.userID
        return stackView
    }()
    
    lazy var nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Metrics.stackViewSpacing
        [nicknameGuideLabel, userNicknameLabel, changeNicknameButton].forEach { stackView.addArrangedSubview($0) }
        userNicknameLabel.text = self.user?.nickname
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
        userEmailLabel.text = self.user?.emailForPasswordLoss
        return stackView
    }()
    
    //MARK: - Initialization
    
    init(userInfo: User) {
        super.init()
        self.user = userInfo
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func setupActions() {
        super.setupActions()
        
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    private func configure() {
        title = "설정"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

//MARK: - Actions

extension AccountManagementViewController {

    @objc private func pressedChangedUserInfoButton(_ sender: UIButton) {
        print("✏️ button tag: \(sender.tag)")
    }
    
    @objc private func pressedNotificationSettingsButton() {
        
    }
    
    @objc private func pressedLogOutButton() {
        
    }
    
    @objc private func pressedUnregisterButton() {
        
    }
    
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct AccountManagementVC: PreviewProvider {
    
    static var previews: some View {
        AccountManagementViewController(userInfo: User()).toPreview()
    }
}
#endif
