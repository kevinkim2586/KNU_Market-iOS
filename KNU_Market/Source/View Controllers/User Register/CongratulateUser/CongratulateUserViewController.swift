import UIKit
import Lottie
import SnapKit

class CongratulateUserViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Style {
        static let labelFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        static let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: Style.labelFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    //MARK: - UI
    
    let animationView = AnimationView()
    
    let congratulateLabel: UILabel = {
        let label = UILabel()
        label.text = "크누마켓 회원가입을 축하합니다!"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .darkGray
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "크누마켓"
        )
        label.textAlignment = .center
        return label
    }()
    
    let firstLabel: UILabel = {
        let label = UILabel()
        label.text = "계속 진행함으로써"
        label.font = Style.labelFont
        label.textColor = .darkGray
        return label
    }()
    
    let termsAndConditionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "이용약관", attributes: Style.buttonAttributes), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedSeeTermsAndConditionsButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "개인정보취급방침", attributes: Style.buttonAttributes), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedSeePrivacyInfoButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        
        let firstLabel = UILabel()
        firstLabel.text = "및"
        firstLabel.textColor = .darkGray
        firstLabel.font = Style.labelFont
        
        let secondLabel = UILabel()
        secondLabel.text = "에 동의합니다."
        secondLabel.textColor = .darkGray
        secondLabel.font = Style.labelFont
    
        [termsAndConditionButton, firstLabel, privacyButton, secondLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 6
        [firstLabel ,innerStackView].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    let goHomeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addBounceAnimationWithNoFeedback()
        button.setTitle("동의하고 진행하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 5
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addTarget(
            self,
            action: #selector(pressedGoHomeButton),
            for: .touchUpInside
        )
        return button
    }()
    

    //MARK: - Initialization
    
    init(userManager: UserManager) {
        super.init()
        self.userManager = userManager
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playAnimation()
        removeAllPreviousObservers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.goHomeButton.isHidden = false
            self.goHomeButton.isUserInteractionEnabled = true
            
        }
    }

    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(animationView)
        view.addSubview(congratulateLabel)
        view.addSubview(firstLabel)
        view.addSubview(containerStackView)
        view.addSubview(goHomeButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        animationView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(400)
        }
        
        goHomeButton.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        containerStackView.snp.makeConstraints { make in
            make.bottom.equalTo(goHomeButton.snp.top).offset(-26)
            make.left.equalTo(view.snp.left).offset(24)
            make.right.equalTo(view.snp.right).offset(-24)
        }
        
        congratulateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(containerStackView.snp.top).offset(-40)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
}

//MARK: - Target Methods
extension CongratulateUserViewController {

    @objc private func pressedGoHomeButton() {
        showProgressBar()
        userManager?.login(
            id: UserRegisterValues.shared.userId,
            password: UserRegisterValues.shared.password
        ) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success: self.changeRootViewControllerToMain()
            case .failure(let error):
                self.showSimpleBottomAlertWithAction(
                    message: error.errorDescription,
                    buttonTitle: "돌아가기"
                ) {
                    self.popToLoginViewController()
                }
            }
        }
    }
    
    @objc private func pressedSeeTermsAndConditionsButton() {
        let url = URL(string: K.URL.termsAndConditionNotionURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func pressedSeePrivacyInfoButton() {
        let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func playAnimation() {
        
        animationView.animation = Animation.named("congratulate1")
        
        animationView.backgroundColor = .white
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
    
    func changeRootViewControllerToMain() {

        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(UIHelper.createMainTabBarController())
    }
    
    func removeAllPreviousObservers() {
        [NickNameInputViewController.self,
         PasswordInputViewController.self,
         EmailInputViewController.self,
         CheckEmailViewController.self].forEach { vc in
            NotificationCenter.default.removeObserver(vc)
        }
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct CongratulateVC: PreviewProvider {
    
    static var previews: some View {
        CongratulateUserViewController(userManager: UserManager()).toPreview()
    }
}
#endif
