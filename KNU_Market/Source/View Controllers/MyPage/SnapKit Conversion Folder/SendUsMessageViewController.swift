import UIKit
import SnapKit

class SendUsMessageViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var networkManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        
        static let labelSidePadding: CGFloat = 16
    }
    
    fileprivate struct Fonts {
        
        static let titleLabel       = UIFont.systemFont(ofSize: 19, weight: .bold)
        static let subtitleLabel    = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let textView         = UIFont.systemFont(ofSize: 15)
    }
    
    fileprivate struct Texts {
        static let textViewPlaceholder         = "개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요 😁"
    }
    
    //MARK: - UI
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.titleLabel
        label.text = "개발팀에게 건의사항 보내기"
        return label
    }()
    
    let kakaoChannelGuideLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.subtitleLabel
        label.textColor = .darkGray
        label.text = "1:1 채팅을 통한 문의를 원하시는 분은 아래 카카오채널로 문의해주세요."
        label.numberOfLines = 2
        return label
    }()
    
    let kakaoChannelLinkButton: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key : Any] = [
            .font: Fonts.subtitleLabel,
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
    
    let timeAvailableLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.subtitleLabel
        label.textColor = .darkGray
        label.text = "(평일, 주말 09:00 ~ 23:00)"
        return label
    }()
    
    let feedbackLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.subtitleLabel
        label.textColor = .darkGray
        label.text = "✻ 건의/제안 사항을 보내주시면 참고하여,\n추후 업데이트에 반영하겠습니다."
        label.numberOfLines = 2
        return label
    }()
    
    let feedbackTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.font = Fonts.textView
        textView.text = Texts.textViewPlaceholder
        textView.textColor = .lightGray
        return textView
    }()
    
    let sendFeedbackBarButtonItem = UIBarButtonItem(
        image: UIImage(systemName: "paperplane"),
        style: .plain,
        target: self,
        action: #selector(pressedSendBarButtonItem)
    )
    
    //MARK: - Initialization
    
    init(networkManager: UserManager) {
        super.init()
        self.networkManager = networkManager
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
        view.addSubview(kakaoChannelGuideLabel)
        view.addSubview(kakaoChannelLinkButton)
        view.addSubview(timeAvailableLabel)
        view.addSubview(feedbackLabel)
        view.addSubview(feedbackTextView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(Metrics.labelSidePadding)
        }
        
        kakaoChannelGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(Metrics.labelSidePadding)
        }
        
        kakaoChannelLinkButton.snp.makeConstraints { make in
            make.top.equalTo(kakaoChannelGuideLabel.snp.bottom).offset(Metrics.labelSidePadding)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        timeAvailableLabel.snp.makeConstraints { make in
            make.top.equalTo(kakaoChannelLinkButton.snp.bottom).offset(6)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        feedbackLabel.snp.makeConstraints { make in
            make.top.equalTo(timeAvailableLabel.snp.bottom).offset(14)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
        }
        
        feedbackTextView.snp.makeConstraints { make in
            make.top.equalTo(feedbackLabel.snp.bottom).offset(24)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.equalToSuperview()
            make.height.equalTo(300)
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

//MARK: - Actions

extension SendUsMessageViewController {
    
    @objc func pressedKakaoChannelLinkButton() {
        let url = URL(string: K.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url)
    }
    
    @objc func pressedSendBarButtonItem() {
        view.endEditing(true)
        
        guard let content = feedbackTextView.text else { return }
        guard content != Texts.textViewPlaceholder else { return }
        showProgressBar()
        
        networkManager?.sendFeedback(content: content) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success:
                self.showSimpleBottomAlert(with: "피드백을 성공적으로 보냈습니다. 소중한 의견 감사합니다.😁")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
}

//MARK: - UITextViewDelegate

extension SendUsMessageViewController: UITextViewDelegate {
    
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
struct SendUsMessageVC: PreviewProvider {
    
    static var previews: some View {
        SendUsMessageViewController(networkManager: UserManager()).toPreview()
    }
}
#endif
