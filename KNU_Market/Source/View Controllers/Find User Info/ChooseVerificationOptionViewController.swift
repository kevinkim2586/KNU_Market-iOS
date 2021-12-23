import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol ChooseVerificationOptionDelegate: AnyObject {
    func didSelectToRegister()
}

class ChooseVerificationOptionViewController: BaseViewController {
    
    //MARK: - Properties
    
    weak var delegate: ChooseVerificationOptionDelegate?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding     = 16.f
        static let buttonCornerRadius   = 10.f
        static let buttonHeight         = 50.f
    }
    
    fileprivate struct Colors {
        static let appColor     = UIColor(named: K.Color.appColor)
    }
    
    fileprivate struct Images {
        static let studentIdImage   = UIImage(systemName: K.Images.studentIdButtonSystemImage)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        static let schoolMail       = UIImage(systemName: K.Images.schoolMailButtonSystemImage)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    fileprivate struct Fonts {
        static let buttonTitleLabel = UIFont.systemFont(ofSize: 15, weight: .bold)
        static let registerButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .medium),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    //MARK: - UI
    
    let titleLabel = UILabel().then {
        $0.font = .preferredFont(
            forTextStyle: .title3,
            compatibleWith: .init(legibilityWeight: .bold)
        )
        $0.text = "어떤 방식으로 인증했었나요?"
        $0.textColor = .black
    }
    
    let detailLabel = UILabel().then {
        $0.text = "✻ 인증을 하지 않으신 회원은 아이디 찾기가 불가능합니다."
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "인증을 하지 않으신 회원"
        )
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .darkGray
    }
    
    let registerButton = UIButton(type: .system).then {
        $0.setAttributedTitle(NSAttributedString(string: "회원가입을 다시 시도해주세요.", attributes: Fonts.registerButtonAttributes), for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
    }
    
    let studentIdButton = UIButton(type: .system).then {
        $0.setTitle("학생증", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = Fonts.buttonTitleLabel
        $0.backgroundColor = UIColor(named: K.Color.appColor) ?? .systemPink
        $0.setImage(Images.studentIdImage, for: .normal)
        $0.tintColor = Colors.appColor
        $0.layer.cornerRadius = Metrics.buttonCornerRadius
        $0.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let schoolMailButton = UIButton(type: .system).then {
        $0.setTitle("웹메일", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = Fonts.buttonTitleLabel
        $0.backgroundColor = Colors.appColor
        $0.setImage(Images.schoolMail, for: .normal)
        $0.layer.cornerRadius = Metrics.buttonCornerRadius
        $0.tintColor = Colors.appColor
        $0.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 30
    }
    
    //MARK: - Initialization
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "아이디 찾기"
        bindUI()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        [studentIdButton, schoolMailButton].forEach { buttonStackView.addArrangedSubview($0) }
        
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(registerButton)
        view.addSubview(buttonStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(26)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(4)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding + 15)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
        setBackBarButtonItemTitle(to: "뒤로")
        setClearNavigationBarBackground()
    }
    
    func bindUI() {
        
        registerButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
                self.delegate?.didSelectToRegister()
            })
            .disposed(by: disposeBag)
        
        
        studentIdButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let vc = FindIdUsingStudentIdViewController(
                    reactor: FindUserInfoViewReactor(userService: UserService(network: Network<UserAPI>()))
                )
                self.pushVC(vc)
            })
            .disposed(by: disposeBag)
        
        schoolMailButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let vc = FindIdUsingWebMailViewController()
                self.pushVC(vc)
            })
            .disposed(by: disposeBag)
    }
    
    func pushVC(_ vc: UIViewController) {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.pushViewController(vc, animated: true)
    }
}
