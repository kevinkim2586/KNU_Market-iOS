import UIKit
import SnapKit
import SDWebImage

class KMPopupViewController: BaseViewController {
    
    //MARK: - Properties
    var imageUid: String?
    var landingUrl: String?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let dismissButtonHeight: CGFloat = 50
    }
    
    fileprivate struct Fonts {
        
        static let findButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.white
        ]
    }
    
    fileprivate struct Images {
        static let dismissButton   = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    //MARK: - UI
    
    let popupImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.image = UIImage(named: "studentID_guide") // TEST
        return imageView
    }()
    
    let doNotSeeForOneDayButton: UIButton = {
        let button = UIButton()
        button.addBounceAnimationWithNoFeedback()
        button.setAttributedTitle(NSAttributedString(
            string: "24시간 보지 않기",
            attributes: Fonts.findButtonAttributes
        ), for: .normal)
        button.addTarget(
            self,
            action: #selector(doNotSeePopupForOneDay),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var dismissButton: UIButton = {
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
    
    init(imageUid: String, landingUrl: String) {
        super.init()
        self.imageUid = imageUid
        self.landingUrl = landingUrl
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configure()
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
            make.center.equalToSuperview()
        }
        
        doNotSeeForOneDayButton.snp.makeConstraints { make in
            make.top.equalTo(popupImageView.snp.bottom).offset(12)
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
        guard let imageUid = imageUid else { return }
        let imageUrl = URL(string: "\(K.API_BASE_URL)media/" + imageUid)
        
        popupImageView.sd_setImage(
            with: imageUrl,
            placeholderImage: nil,
            options: .continueInBackground,
            completed: nil
        )
    }
}

//MARK: - Target Methods

extension KMPopupViewController {
    
    @objc private func openLandingUrl() {
        guard let landingUrl = landingUrl else { return }
        guard let url = URL(string: landingUrl) else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    @objc private func doNotSeePopupForOneDay() {
        
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct KMPopupVC: PreviewProvider {
    
    static var previews: some View {
        KMPopupViewController(imageUid: "", landingUrl: "").toPreview()
    }
}
#endif
