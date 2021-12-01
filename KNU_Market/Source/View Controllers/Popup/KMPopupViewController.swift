import UIKit
import SnapKit
import SDWebImage

class KMPopupViewController: BaseViewController {
    
    //MARK: - Properties
    private var popupManager: PopupManager?
    private var popupUid: Int?
    private var mediaUid: String?
    private var landingUrl: String?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let dismissButtonHeight: CGFloat = 50
    }
    
    fileprivate struct Fonts {
        
        static let doNotSeeForOneDayButton: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.5, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.white
        ]
    }
    
    fileprivate struct Images {
        static let dismissButton   = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    //MARK: - UI
    
    lazy var popupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pressedPopupImage))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    let doNotSeeForOneDayButton: UIButton = {
        let button = UIButton()
        button.addBounceAnimationWithNoFeedback()
        button.setAttributedTitle(NSAttributedString(
            string: "24시간 보지 않기",
            attributes: Fonts.doNotSeeForOneDayButton
        ), for: .normal)
        button.addTarget(
            self,
            action: #selector(doNotSeePopupForOneDay),
            for: .touchUpInside
        )
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkGray
        button.setImage(Images.dismissButton, for: .normal)
        button.widthAnchor.constraint(equalToConstant: Metrics.dismissButtonHeight).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.dismissButtonHeight).isActive = true
        button.layer.cornerRadius = Metrics.dismissButtonHeight / 2
        button.addBounceAnimationWithNoFeedback()
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Initialization
    
    init(popupManager: PopupManager?, popupUid: Int, mediaUid: String, landingUrl: String) {
        super.init()
        self.popupManager = popupManager
        self.popupUid = popupUid
        self.mediaUid = mediaUid
        self.landingUrl = landingUrl
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
        
        view.addSubview(popupImageView)
        view.addSubview(doNotSeeForOneDayButton)
        view.addSubview(dismissButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        popupImageView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.8)
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
            make.top.equalToSuperview().inset(180)
            make.centerX.equalToSuperview()
        }
        
        doNotSeeForOneDayButton.snp.makeConstraints { make in
            make.top.equalTo(popupImageView.snp.bottom).offset(15.3)
            make.centerX.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(doNotSeeForOneDayButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }
    
    override func setupActions() {
        super.setupActions()
    }
    
    private func configure() {
        guard let mediaUid = mediaUid else { return }
        popupImageView.sd_setImage(
            with: URL(string: K.MEDIA_REQUEST_URL + mediaUid),
            placeholderImage: nil,
            options: .continueInBackground,
            completed: nil
        )
    }
}

//MARK: - Target Methods

extension KMPopupViewController {
    
    @objc private func pressedPopupImage() {
        incrementPopupViewCount()
        openLandingUrl()
    }
    
    private func openLandingUrl() {
        guard let landingUrl = landingUrl else { return }
        guard let url = URL(string: landingUrl) else { return }
        UIApplication.shared.open(url, options: [:])
      
    }
    
    private func incrementPopupViewCount() {
        guard let popupUid = popupUid else { return }
        popupManager?.incrementPopupViewCount(popupUid: popupUid)
    }
    
    @objc private func doNotSeePopupForOneDay() {
        popupManager?.configureToNotSeePopupForOneDay()
        dismiss(animated: true)
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct KMPopupVC: PreviewProvider {
    
    static var previews: some View {
        KMPopupViewController(popupManager: PopupManager(), popupUid: 0, mediaUid: "", landingUrl: "").toPreview()
    }
}
#endif
