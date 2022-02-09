//
//  LoginViewController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/18.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa


class LoginViewController: BaseViewController, View {
    
    typealias Reactor = LoginViewReactor
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 70.f
        static let textFieldHeight  = 50.f
    }
    
    fileprivate struct Texts {
        static let idGuideString            = "2021년 10월 8일 이전에 가입한 회원의 아이디는 웹메일(@knu.ac.kr) 형식입니다."
        static let idGuideStringToChange    = "2021년 10월 8일 이전에 가입한 회원"
        
        static let registerLabel            = "아직 회원이 아니신가요? 회원가입"
        
        static let idInfoAttributedString: NSAttributedString = Texts.idGuideString.attributedStringWithColor(
            [Texts.idGuideStringToChange],
            color: UIColor(named: K.Color.appColor) ?? .systemPink,
            characterSpacing: nil
        )
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
    
    let appLogoImageView = UIImageView().then {
        $0.image = UIImage(named: "appLogo2")
        $0.contentMode = .scaleAspectFit
    }
    
    let appNameLabel = UILabel().then {
        $0.text = "크누마켓"
        $0.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        $0.textColor = UIColor(named: K.Color.appColorEnforced)
    }
    
    let appCopyLabel = UILabel().then {
        $0.text = "우리가 함께 사는 곳"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor(named: K.Color.appColorEnforced)
    }
    
    let infoButton = UIButton(type: .system).then {
        $0.setImage(Images.infoButton, for: .normal)
    }
    
    let idTextField = UITextField().then {
        $0.borderStyle = .none
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = Metrics.textFieldHeight / 2
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
        $0.layer.masksToBounds = true
        $0.font = Fonts.textFieldFont
        $0.placeholder = "아이디 입력"
        $0.autocapitalizationType = .none
    }
    
    let passwordTextField = UITextField().then {
        $0.borderStyle = .none
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = Metrics.textFieldHeight / 2
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
        $0.layer.masksToBounds = true
        $0.font = Fonts.textFieldFont
        $0.placeholder = "비밀번호 입력"
        $0.isSecureTextEntry = true
        $0.autocapitalizationType = .none
    }
    
    let loginButton = UIButton(type: .system).then {
        $0.setTitle("로그인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius  = Metrics.textFieldHeight / 2
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let registerButton = UIButton(type: .system).then {
        $0.setAttributedTitle(Fonts.registerButtonAttributes, for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let findIdButton = UIButton(type: .system).then {
        $0.setAttributedTitle(NSAttributedString(
            string: "아이디 찾기",
            attributes: Fonts.findButtonAttributes
        ), for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
    }
    
    let findPwButton = UIButton(type: .system).then {
        $0.setAttributedTitle(NSAttributedString(
            string: "비밀번호 찾기",
            attributes: Fonts.findButtonAttributes
        ), for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
    }
    
    let findInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 50
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
        
        [findIdButton, findPwButton].forEach { findInfoStackView.addArrangedSubview($0) }
        view.addSubview(findInfoStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        appLogoImageView.snp.makeConstraints {
            $0.width.height.equalTo(120)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(110)
            $0.centerX.equalToSuperview()
        }
        
        appNameLabel.snp.makeConstraints {
            $0.top.equalTo(appLogoImageView.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        
        appCopyLabel.snp.makeConstraints {
            $0.top.equalTo(appNameLabel.snp.bottom).offset(6)
            $0.centerX.equalToSuperview()
        }
        
        findInfoStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.centerX.equalToSuperview()
        }
        
        registerButton.snp.makeConstraints {
            $0.bottom.equalTo(findInfoStackView.snp.top).offset(-6)
            $0.centerX.equalToSuperview()
        }
        
        loginButton.snp.makeConstraints {
            $0.bottom.equalTo(registerButton.snp.top).offset(-15)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.bottom.equalTo(loginButton.snp.top).offset(-15)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        idTextField.snp.makeConstraints {
            $0.bottom.equalTo(passwordTextField.snp.top).offset(-15)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        infoButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-240)
            $0.width.height.equalTo(32)
            $0.left.equalTo(idTextField.snp.right).offset(16)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: LoginViewReactor) {
        
        // Input
        
        idTextField.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updateId($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updatePassword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .asObservable()
            .map { Reactor.Action.login }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.presentRegisterVC()
            })
            .disposed(by: disposeBag)
        
        findIdButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let findIdVC = ChooseVerificationOptionViewController()
                findIdVC.delegate = self
                self.presentVC(findIdVC)
            })
            .disposed(by: disposeBag)
        
        findPwButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let findPwVC = FindPasswordViewController(
                    reactor: FindUserInfoViewReactor(userService: UserService(network: Network<UserAPI>(), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))
                )
                self.presentVC(findPwVC)
            })
            .disposed(by: disposeBag)
        
        infoButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.presentKMAlertOnMainThread(
                    title: "안내",
                    message: "",
                    buttonTitle: "확인",
                    attributedMessageString: Texts.idInfoAttributedString
                )
            })
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
            .subscribe { (vc, errorMessage) in
                self.presentKMAlertOnMainThread(
                    title: "로그인 실패",
                    message: errorMessage!
                )
            }
            .disposed(by: disposeBag)
    }
    
    func presentVC(_ vc: UIViewController) {
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
}

//MARK: - ChooseVerificationOptionDelegate

extension LoginViewController: ChooseVerificationOptionDelegate {
    
    func didSelectToRegister() {
        presentRegisterVC()
    }
}



