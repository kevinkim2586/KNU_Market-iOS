import UIKit
import SnapKit

class InitialViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 70
        static let textFieldHeight: CGFloat     = 50
    }
    
    fileprivate struct Texts {
        static let idGuideString            = "2021년 10월 8일 이전에 가입한 회원의 아이디는 웹메일(@knu.ac.kr) 형식입니다."
        static let idGuideStringToChange    = "2021년 10월 8일 이전에 가입한 회원"
        
        static let registerLabel            = "아직 회원이 아니신가요? 회원가입"
    }
    
    fileprivate struct Fonts {
        static let textFieldFont        = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let registerButtonAttributes: NSAttributedString = Texts.registerLabel.attributedStringWithColor(
            ["회원가입"],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
        static let findButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    fileprivate struct Images {
        static let infoButton   = UIImage(systemName: "questionmark.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink)
        
    }
    
    //MARK: - UI
    
    let appLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "appLogo2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "크누마켓"
        label.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        label.textColor = UIColor(named: K.Color.appColorEnforced)
        return label
    }()
    
    let appCopyLabel: UILabel = {
        let label = UILabel()
        label.text = "우리가 함께 사는 곳"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(named: K.Color.appColorEnforced)
        return label
    }()
    
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.infoButton, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var idTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = Metrics.textFieldHeight / 2
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12
        textField.layer.masksToBounds = true
        textField.font = Fonts.textFieldFont
        textField.placeholder = "아이디 입력"
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = Metrics.textFieldHeight / 2
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 12
        textField.layer.masksToBounds = true
        textField.font = Fonts.textFieldFont
        textField.placeholder = "비밀번호 입력"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.layer.cornerRadius  = Metrics.textFieldHeight / 2
        button.addBounceAnimationWithNoFeedback()
        button.addTarget(
            self,
            action: #selector(pressedLoginButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(Fonts.registerButtonAttributes, for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.addTarget(
            self,
            action: #selector(pressedRegisterButton),
            for: .touchUpInside
        )
        button.addBounceAnimationWithNoFeedback()
        return button
    }()
    
    let findIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(
            string: "아이디 찾기",
            attributes: Fonts.findButtonAttributes
        ), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedFindIdButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let findPwButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(
            string: "비밀번호 찾기",
            attributes: Fonts.findButtonAttributes
        ), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedFindPwButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var findInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 50
        [findIdButton, findPwButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    //MARK: - Initialization
    
    init(userManager: UserManager) {
        super.init()
        self.userManager = userManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(appLogoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(appCopyLabel)
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(infoButton)
        view.addSubview(registerButton)
        view.addSubview(findInfoStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        appLogoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
            make.centerX.equalToSuperview()
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(appLogoImageView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        appCopyLabel.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        findInfoStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(findInfoStackView.snp.top).offset(-6)
            make.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(registerButton.snp.top).offset(-15)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.bottom.equalTo(loginButton.snp.top).offset(-15)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        idTextField.snp.makeConstraints { make in
            make.bottom.equalTo(passwordTextField.snp.top).offset(-15)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        infoButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-240)
            make.width.height.equalTo(32)
            make.left.equalTo(idTextField.snp.right).offset(16)
        }
    }
    
    func presentVC(_ vc: UIViewController) {
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
}

//MARK: - IBActions

extension InitialViewController {
    
    @objc private func pressedLoginButton() {
        guard let id = idTextField.text, let password = passwordTextField.text else { return }
        guard id.count > 0, password.count > 0 else { return }
        
        showProgressBar()
        
        userManager?.login(id: id, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.goToHomeScreen()
            case .failure(let error):
                self.presentCustomAlert(title: "로그인 실패", message: error.errorDescription)
            }
            dismissProgressBar()
        }
    }
    
    @objc private func pressedRegisterButton() {
        
        let vc = IDInputViewController(userManager: UserManager())
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.tintColor = UIColor.black
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
        
    }
    
    @objc private func pressedFindIdButton() {
        let findIdVC = ChooseVerificationOptionViewController()
        findIdVC.delegate = self
        presentVC(findIdVC)
    }
    
    @objc private func pressedFindPwButton() {
        let findPwVC = FindPasswordViewController()
        presentVC(findPwVC)
    }
    
    @objc private func pressedInfoButton() {
        let attributedMessageString: NSAttributedString = Texts.idGuideString.attributedStringWithColor(
            [Texts.idGuideStringToChange],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
        
        presentKMAlertOnMainThread(
            title: "안내",
            message: "",
            buttonTitle: "확인",
            attributedMessageString: attributedMessageString
        )
    }
}

//MARK: - ChooseVerificationOptionDelegate

extension InitialViewController: ChooseVerificationOptionDelegate {
    
    func didSelectToRegister() {
        let vc = IDInputViewController(userManager: UserManager())
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.tintColor = UIColor.black
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
}



#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct InitialVC: PreviewProvider {
    
    static var previews: some View {
        InitialViewController(userManager: UserManager()).toPreview()
    }
}
#endif
