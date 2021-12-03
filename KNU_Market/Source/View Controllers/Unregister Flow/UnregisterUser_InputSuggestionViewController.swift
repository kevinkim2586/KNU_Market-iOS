import UIKit
import SnapKit

class UnregisterUser_InputSuggestionViewController: BaseViewController {
    
    private var userManager: UserManager?
    
    //MARK: - Properties
    
    //MARK: - Constants
    fileprivate struct Metrics {
        
        static let labelSidePadding: CGFloat = 16
    }
    
    fileprivate struct Fonts {
        
        static let titleLabel       = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    fileprivate struct Texts {
        static let titleLabel           = "크누마켓팀이 개선했으면\n하는 점을 알려주세요."
        static let mailGuideLabel       = "웹메일 인증과 관련된 문의는 카카오채널을\n통해 실시간으로 도와드리겠습니다."
        static let textViewPlaceholder  = "✏️ 개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요."
    }
    
    //MARK: - UI
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.titleLabel
        label.font = Fonts.titleLabel
        label.textColor = .darkGray
        label.changeTextAttributeColor(fullText: Texts.titleLabel, changeText: "크누마켓")
        label.numberOfLines = 2
        return label
    }()
    
    let feedbackLabel: UILabel = {
        let label = UILabel()
        label.text = "피드백을 반영하여 적극적으로 개선하겠습니다."
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    let mailGuideLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.mailGuideLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.changeTextAttributeColor(fullText: Texts.mailGuideLabel, changeText: "웹메일 인증과 관련된 문의")
        label.numberOfLines = 2
        return label
    }()
    
    let kakaoChannelLinkButton: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.systemBlue
        ]
        let linkString: String = "https://pf.kakao.com/_PjLHs"
        button.setAttributedTitle(NSAttributedString(string: linkString, attributes: attributes), for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedKakaoChannelLinkButton),
            for: .touchUpInside
        )
        return button
    }()
    
    let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = Texts.textViewPlaceholder
        textView.textColor = UIColor.lightGray
        return textView
    }()

    
    lazy var sendFeedbackBarButtonItem = UIBarButtonItem(
        title: "완료",
        style: .done,
        target: self,
        action: #selector(pressedSendBarButtonItem)
    )
    
    
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
        configure()
    }
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.rightBarButtonItem = sendFeedbackBarButtonItem
        
        view.addSubview(titleLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(mailGuideLabel)
        view.addSubview(kakaoChannelLinkButton)
        view.addSubview(feedbackTextView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        feedbackLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        mailGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(feedbackLabel.snp.bottom).offset(30)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        kakaoChannelLinkButton.snp.makeConstraints { make in
            make.top.equalTo(mailGuideLabel.snp.bottom).offset(15)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        feedbackTextView.snp.makeConstraints { make in
            make.top.equalTo(kakaoChannelLinkButton.snp.bottom).offset(25)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    private func configure() {
        feedbackTextView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }


}

//MARK: - Target Methods

extension UnregisterUser_InputSuggestionViewController {
    
    @objc private func pressedSendBarButtonItem() {
        feedbackTextView.resignFirstResponder()
        
        guard var feedback = feedbackTextView.text else { return }
        guard feedback != Texts.textViewPlaceholder else {
            presentCustomAlert(title: "회원 탈퇴 사유 입력", message: "회원 탈퇴 사유를 입력해 주세요. 짧게라도 작성해주시면 감사하겠습니다 :)")
            return
        }
        
        showProgressBar()
        feedback = "회원 탈퇴 사유: \(feedback)"
        
        let group = DispatchGroup()
        group.enter()
        userManager?.sendFeedback(content: feedback) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success: break
            case .failure: self.showSimpleBottomAlert(with: "피드백 보내기에 실패하였습니다. 잠시 후 다시 시도해주세요.")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.userManager?.unregisterUser { [weak self] result in
                dismissProgressBar()
                guard let self = self else { return }
                switch result {
                case .success: self.popToInitialViewController()
                case .failure(let error):
                    self.presentCustomAlert(title: "회원 탈퇴 실패", message: error.errorDescription)
                }
            }
        }
    }
    
    @objc private func pressedKakaoChannelLinkButton() {
        let url = URL(string: K.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
}


//MARK: - UITextViewDelegate

extension UnregisterUser_InputSuggestionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = Texts.textViewPlaceholder
            textView.textColor = UIColor.lightGray
            return
        }
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct UnRegisterUser_InputSuggestionVC: PreviewProvider {
    
    static var previews: some View {
        UnregisterUser_InputSuggestionViewController(userManager: UserManager()).toPreview()
    }
}
#endif

