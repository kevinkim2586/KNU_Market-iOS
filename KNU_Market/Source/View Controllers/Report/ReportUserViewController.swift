import UIKit
import SnapKit

class ReportUserViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var reportManager: ReportManager?
    
    private var userToReport: String?
    private var postUid: String?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 16
    }
    
    fileprivate struct Texts {
        static let detailLabelText: String      = "🥷🏻 사기가 의심되거나 사기를 당하셨나요?\n🤬 부적절한 언어를 사용했나요?\n🤔 아래에 신고 사유를 적어서 보내주세요."
        static let textViewPlaceholder: String  = "신고 내용을 적어주세요. 신고가 접수되면 크누마켓 팀이 검토 후 조치하도록 할게요 :)"
        
    }
    
    //MARK: - UI
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .darkGray
        button.addTarget(
            self,
            action: #selector(pressedDismissButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .darkGray
        label.text = "\(userToReport ?? "해당 유저")을(를) 신고하시겠습니까?"
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.text = Texts.detailLabelText
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.numberOfLines = 3
        label.addInterlineSpacing(spacingValue: 10)
        return label
    }()
    
    lazy var reportTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 10.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.text = Texts.textViewPlaceholder
        textView.textColor = .lightGray
        textView.delegate = self
        return textView
    }()
    
    let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고 접수", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.layer.cornerRadius = 5
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.addBounceAnimationWithNoFeedback()
        button.addTarget(
            self,
            action: #selector(pressedReportButton),
            for: .touchUpInside
        )
        return button
    }()
    

    //MARK: - Initialization
    
    init(reportManager: ReportManager, userToReport: String, postUid: String) {
        super.init()
        self.reportManager = reportManager
        self.userToReport = userToReport
        self.postUid = postUid
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
        
        view.addSubview(dismissButton)
        view.addSubview(titleLabel)
        view.addSubview(detailLabel)
        view.addSubview(reportTextView)
        view.addSubview(reportButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        reportTextView.snp.makeConstraints { make in
            make.height.equalTo(260)
            make.top.equalTo(detailLabel.snp.bottom).offset(40)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(reportTextView.snp.bottom).offset(16)
            make.centerX.equalTo(view.snp.centerX)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
}

//MARK: - Target Methods

extension ReportUserViewController {
    
    @objc private func pressedReportButton() {
        view.endEditing(true)
        if !validateUserInput() { return }
        showProgressBar()
        let model = ReportUserRequestDTO(
            user: userToReport ?? "",
            content: reportTextView.text!,
            postUID: postUid ?? ""
        )
        reportManager?.reportUser(with: model) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success:
                self.showSimpleBottomAlert(with: "신고가 정상적으로 접수되었습니다. 감사합니다.😁")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.dismiss(animated: true)
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    @objc private func pressedDismissButton() {
        dismiss(animated: true)
    }
}

//MARK: - Input Validation

extension ReportUserViewController {
    
    func validateUserInput() -> Bool {
        guard reportTextView.text != Texts.textViewPlaceholder else {
            self.showSimpleBottomAlert(with: "신고 내용을 3글자 이상 적어주세요 👀")
            return false
        }
        guard let content = reportTextView.text else { return false }
        
        if content.count >= 3 { return true }
        else {
            self.showSimpleBottomAlert(with: "신고 내용을 3글자 이상 적어주세요 👀")
            return false
        }
    }
}

//MARK: - UITextViewDelegate

extension ReportUserViewController: UITextViewDelegate {
    
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
struct ReportUserVC: PreviewProvider {
    
    static var previews: some View {
        ReportUserViewController(reportManager: ReportManager(), userToReport: "연어참치롤", postUid: "").toPreview()
    }
}
#endif
