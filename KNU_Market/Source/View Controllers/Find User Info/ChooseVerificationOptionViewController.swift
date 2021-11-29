import UIKit
import SnapKit

protocol ChooseVerificationOptionDelegate: AnyObject {
    func didSelectToRegister()
}

class ChooseVerificationOptionViewController: BaseViewController {
    
    //MARK: - Properties
    
    weak var delegate: ChooseVerificationOptionDelegate?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 16
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
        label.text = "어떤 방식으로 인증했었나요?"
        label.textColor = .black
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "✻ 인증을 하지 않으신 회원은 아이디 찾기가 불가능합니다."
        label.changeTextAttributeColor(
            fullText: label.text!,
            changeText: "인증을 하지 않으신 회원"
        )
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15, weight: .medium),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        button.setAttributedTitle(NSAttributedString(string: "회원가입을 다시 시도해주세요.", attributes: attributes), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedRegisterButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let studentIdButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학생증", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitleLabel
        button.backgroundColor = UIColor(named: K.Color.appColor) ?? .systemPink
        button.setImage(Images.studentIdImage, for: .normal)
        button.tintColor = Colors.appColor
        button.layer.cornerRadius = Metrics.buttonCornerRadius
        button.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        button.addBounceAnimationWithNoFeedback()
        button.addTarget(
            self,
            action: #selector(pressedVerifiedUsingStudentIdButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let schoolMailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("웹메일", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = Fonts.buttonTitleLabel
        button.backgroundColor = Colors.appColor
        button.setImage(Images.schoolMail, for: .normal)
        button.layer.cornerRadius = Metrics.buttonCornerRadius
        button.tintColor = Colors.appColor
        button.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight).isActive = true
        button.addBounceAnimationWithNoFeedback()
        button.addTarget(
            self,
            action: #selector(pressedVerifiedUsingEmailButton),
            for: .touchUpInside
        )
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
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
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
    
    private func configure() {
        title = "아이디 찾기"
    }
    
}

//MARK: - Target Methods

extension ChooseVerificationOptionViewController {
    
    @objc private func pressedRegisterButton() {
        dismiss(animated: true)
        delegate?.didSelectToRegister()
    }
    
    @objc private func pressedVerifiedUsingStudentIdButton() {
        let vc = FindIdUsingStudentIdViewController()
        pushVC(vc)
    }
    
    @objc private func pressedVerifiedUsingEmailButton(_ sender: UIButton) {
        let vc = FindIdUsingWebMailViewController()
        pushVC(vc)
    }
    
    func pushVC(_ vc: UIViewController) {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.pushViewController(vc, animated: true)
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct ChooseVerificationOptionVC: PreviewProvider {

    static var previews: some View {
        ChooseVerificationOptionViewController().toPreview()
    }
}
#endif
