import UIKit
import SnapKit
import SDWebImage
import Hero

class ChatImageViewController: BaseViewController {
    
    //MARK: - Properties
    
    var imageUrl: URL?
    var heroId: String?
    
    //MARK: - Constants
    
    fileprivate struct Images {
        static let dismissButton = UIImage(systemName: "xmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor.white)
    }
    
    //MARK: - UI
    
    lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        return scrollView
    }()
    
    lazy var chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.white
        return imageView
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.dismissButton, for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedDismissButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    
    init(imageUrl: URL, heroId: String) {
        super.init()
        self.imageUrl = imageUrl
        self.heroId = heroId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(imageScrollView)
        view.addSubview(dismissButton)
        imageScrollView.addSubview(chatImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        imageScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    
        dismissButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.top.equalToSuperview().offset(60)
            $0.right.equalToSuperview().offset(-15)
        }
        
        chatImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.90)
    }
    
    private func configure() {
        configureChatImageView()
        configurePanGesture()
    }
    
    private func configureChatImageView() {
        if let heroId = heroId {
            chatImageView.heroID = heroId
        }
        chatImageView.sd_setImage(
            with: imageUrl,
            placeholderImage: nil,
            options: .continueInBackground,
            completed: nil
        )
    }
    
    private func configurePanGesture() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGesture)
        )
        chatImageView.addGestureRecognizer(panGesture)
    }

}

//MARK: - Target Methods

extension ChatImageViewController {
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        
        switch sender.state {
        case .began:
            hero.dismissViewController()
        case .changed:
            Hero.shared.update(progress)
            
            let currentPosition = CGPoint(x: translation.x  + chatImageView.center.x, y: translation.y + chatImageView.center.y)
            Hero.shared.apply(modifiers: [.position(currentPosition)], to: chatImageView)
        default:
            if progress + sender.velocity(in: nil).y / view.bounds.height > 0.2 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
    @objc private func pressedDismissButton() {
        hero.dismissViewController()
        dismissVC()
    }
}

//MARK: - UIScrollViewDelegate

extension ChatImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return chatImageView
    }
}
