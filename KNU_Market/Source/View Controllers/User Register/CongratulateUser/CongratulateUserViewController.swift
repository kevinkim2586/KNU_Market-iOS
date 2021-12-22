import UIKit
import Lottie
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

class CongratulateUserViewController: BaseViewController, ReactorKit.View {

    typealias Reactor = CongratulateUserViewReactor
    
    //MARK: - Properties
    
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
    
    let congratulateLabel = UILabel().then {
        $0.text = "크누마켓 회원가입을 축하합니다!"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.textColor = .darkGray
        $0.changeTextAttributeColor(
            fullText: $0.text!,
            changeText: "크누마켓"
        )
        $0.textAlignment = .center
    }
    
    let firstLabel = UILabel().then {
        $0.text = "계속 진행함으로써"
        $0.font = Style.labelFont
        $0.textColor = .darkGray
    }
    
    let termsAndConditionButton = UIButton(type: .system).then {
        $0.setAttributedTitle(NSAttributedString(string: "이용약관", attributes: Style.buttonAttributes), for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
    }
    
    let privacyButton = UIButton(type: .system).then {
        $0.setAttributedTitle(NSAttributedString(string: "개인정보취급방침", attributes: Style.buttonAttributes), for: .normal)
        $0.setTitleColor(.darkGray, for: .normal)
    }
    
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
    
    let goHomeButton = UIButton(type: .system).then {
        $0.addBounceAnimationWithNoFeedback()
        $0.setTitle("동의하고 진행하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.isHidden = true
        $0.isUserInteractionEnabled = false
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor(named: K.Color.appColor)
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
        playAnimation()
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
        
        animationView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        goHomeButton.snp.makeConstraints {
            $0.width.equalTo(170)
            $0.height.equalTo(50)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        containerStackView.snp.makeConstraints {
            $0.bottom.equalTo(goHomeButton.snp.top).offset(-26)
            $0.left.equalTo(view.snp.left).offset(24)
            $0.right.equalTo(view.snp.right).offset(-24)
        }
        
        congratulateLabel.snp.makeConstraints {
            $0.bottom.equalTo(containerStackView.snp.top).offset(-40)
            $0.left.equalTo(view.snp.left).offset(20)
            $0.right.equalTo(view.snp.right).offset(-20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    //MARK: - Binding
    
    func bind(reactor: CongratulateUserViewReactor) {
        
        // Input
        
        termsAndConditionButton.rx.tap
            .subscribe(onNext: { _ in
                let url = URL(string: K.URL.termsAndConditionNotionURL)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        privacyButton.rx.tap
            .subscribe(onNext: { _ in
                let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        goHomeButton.rx.tap
            .asObservable()
            .map { Reactor.Action.goHome }
            .bind(to: reactor.action)
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
            .map { $0.isLoggedIn }
            .asObservable()
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.goToHomeScreen()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, errorMessage) in
                self.showSimpleBottomAlertWithAction(
                    message: errorMessage!,
                    buttonTitle: "돌아가기"
                ) {
                    self.popToLoginViewController()
                }
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - Target Methods
extension CongratulateUserViewController {

    func playAnimation() {
        animationView.animation = Animation.named("congratulate1")
        animationView.backgroundColor = .white
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI
@available(iOS 13.0, *)
struct CongratulateVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        CongratulateUserViewController(
            reactor: CongratulateUserViewReactor(userService: UserService(network: Network<UserAPI>(plugins: [AuthPlugin()])))
        ).toPreview()
    }
}
#endif
