import UIKit
import SnapKit
import ImageSlideshow
import SDWebImage
import RxSwift
import RxCocoa

class PostHeaderView: UIView {
    
    //MARK: - Properties
    
    weak var currentVC: UIViewController?
    
    private var imageSources: [InputSource]?
    private var postTitle: String?
    private var profileImageUid: String?
    private var userNickname: String?
    private var locationName: String?
    private var dateString: String?
    private var viewCount: String?
    
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        
        static let titleViewHeight: CGFloat         = 100
        static let iconImageViewHeight: CGFloat     = 20
    }
    
    //MARK: - UI
    
    lazy var imageSlideShow: ImageSlideshow = {
        let slideShow = ImageSlideshow()
        slideShow.layer.cornerRadius = 15
        slideShow.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.pressedImage)
        )
        
        slideShow.addGestureRecognizer(recognizer)
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.slideshowInterval = 5
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customBottom(padding: 75))
        return slideShow
    }()
    
    let titleContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 1
        return view
    }()
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        label.textAlignment = .center
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.defaultAvatar)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Metrics.iconImageViewHeight / 2
        return imageView
    }()
    
    let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    let locationMarkerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: K.Images.locationIcon)
        return imageView
    }()
    
    let locationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    let viewCountLabel: UILabel = {
        let label = UILabel()
        label.text = "조회 "
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(frame: CGRect, currentVC: UIViewController) {
        super.init(frame: frame)
        self.currentVC = currentVC
        setupLayout()
        setupConstraints()
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        addSubview(imageSlideShow)
        addSubview(titleContainerView)
        titleContainerView.addSubview(postTitleLabel)
        titleContainerView.addSubview(profileImageView)
        titleContainerView.addSubview(userNicknameLabel)
        titleContainerView.addSubview(locationMarkerImageView)
        titleContainerView.addSubview(locationNameLabel)
        addSubview(dateLabel)
        addSubview(viewCountLabel)
    }
    
    private func setupConstraints() {
        
        imageSlideShow.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.85)
        }
        
        titleContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-40)
            $0.height.equalTo(100)
        }
        
        postTitleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.iconImageViewHeight)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        userNicknameLabel.snp.makeConstraints {
            $0.left.equalTo(profileImageView.snp.right).offset(5)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        locationNameLabel.snp.makeConstraints {
            $0.right.bottom.equalToSuperview().inset(10)
        }
        
        locationMarkerImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.iconImageViewHeight)
            $0.right.equalTo(locationNameLabel.snp.left).offset(-5)
            $0.bottom.equalToSuperview().offset(-10)
        }

        dateLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-15)
            $0.left.equalToSuperview().offset(20)
        }
        
        viewCountLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-15)
            $0.right.equalToSuperview().offset(-20)
        }
    }
    
    //MARK: - Data Configuration
    
    func configure(
        imageSources: [InputSource],
        postTitle: String,
        profileImageUid: String,
        userNickname: String,
        locationName: String,
        dateString: String,
        viewCount: String
    ) {
        
        imageSources.isEmpty
        ? imageSlideShow.setImageInputs([ImageSource(image: UIImage(named: K.Images.defaultItemImage)!)])
        : imageSlideShow.setImageInputs(imageSources)
        

        postTitleLabel.text = postTitle
        
        profileImageView.sd_setImage(
            with: URL(string: K.MEDIA_REQUEST_URL + "\(profileImageUid)"),
            placeholderImage: UIImage(named: K.Images.defaultAvatar),
            options: .continueInBackground
        )
        
        userNicknameLabel.text = userNickname
        locationNameLabel.text = locationName
        dateLabel.text = dateString
        viewCountLabel.text = "\(viewCount)"
    }
    
    private func configureImageSlideShow() {
        guard let imageSources = imageSources else {
            return
        }
        imageSources.isEmpty
        ? imageSlideShow.setImageInputs([ImageSource(image: UIImage(named: K.Images.defaultItemImage)!)])
        : imageSlideShow.setImageInputs(imageSources)
    }

}

//MARK: - Target Methods

extension PostHeaderView {
    
    @objc func pressedImage() {
        let fullScreenController = imageSlideShow.presentFullScreenController(from: currentVC ?? UIViewController())
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
    }
}
