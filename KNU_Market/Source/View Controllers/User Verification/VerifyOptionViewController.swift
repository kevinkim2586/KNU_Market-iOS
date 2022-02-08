import UIKit
import SnapKit
import RxSwift
import ReactorKit

class VerifyOptionViewController: BaseViewController, View {
    
    typealias Reactor = VerifyOptionViewReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let buttonCornerRadius: CGFloat  = 10
        static let buttonHeight: CGFloat        = 50
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
    }
    
    //MARK: - UI
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(
            forTextStyle: .title3,
            compatibleWith: .init(legibilityWeight: .bold)
        )
        label.text = "어떤 방식으로 인증하시겠어요?"
        label.textColor = .black
        return label
    }()
    
    let studentIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학생증 인증하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitleLabel
        button.backgroundColor = UIColor(named: K.Color.appColor) ?? .systemPink
        button.setImage(Images.studentIdImage, for: .normal)
        button.tintColor = Colors.appColor
        button.layer.cornerRadius = Metrics.buttonCornerRadius
        button.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        button.addBounceAnimationWithNoFeedback()
        return button
    }()
    
    let schoolMailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("웹메일로 인증하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitleLabel
        button.backgroundColor = Colors.appColor
        button.setImage(Images.schoolMail, for: .normal)
        button.layer.cornerRadius = Metrics.buttonCornerRadius
        button.tintColor = Colors.appColor
        button.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        button.addBounceAnimationWithNoFeedback()
        return button
    }()
    
    lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        [studentIdButton, schoolMailButton].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
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
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(titleLabel)
        view.addSubview(buttonStackView)
    }
    
    override func setupConstraints() {
        super.setupLayout()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.left.equalTo(view.snp.left).offset(16)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
        }
    }
    
    func bind(reactor: VerifyOptionViewReactor) {
        
        // Input
        
        studentIdButton.rx.tap
            .map { Reactor.Action.verifyUsingStudentId }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        schoolMailButton.rx.tap
            .map { Reactor.Action.verifyUsingSchoolEmail }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }

    private func configure() {
        title = "학생 인증하기"
        setBackBarButtonItemTitle()
//        if detectIfVerifiedUser() {
//            presentCustomAlert(title: "인증 회원 안내", message: "이미 인증된 회원입니다.\n이제 공동구매를 즐겨보세요!")
//            navigationController?.popViewController(animated: true)
//        }
    }
    
}

//MARK: - Target Actions

extension VerifyOptionViewController {
    
    @objc private func pressedVerifyUsingStudentIdButton() {
        let vc = StudentIdGuideViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func pressedVerifyUsingEmailButton() {
        let vc = EmailVerificationViewController(
            reactor: EmailVerificationViewReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()]), userDefaultsPersistenceService: UserDefaultsPersistenceService(userDefaultsGenericService: UserDefaultsGenericService.shared)))
        )
       
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

