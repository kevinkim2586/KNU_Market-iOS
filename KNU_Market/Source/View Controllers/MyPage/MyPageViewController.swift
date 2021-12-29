import UIKit
import Photos
import SnapKit

class MyPageViewController: BaseViewController {
    
    //MARK: - Properties
    
    var viewModel: MyPageViewModel!
    
    //MARK: - Constants
    
    struct Metrics {
        static let profileImageButtonHeight = 120.f
    }
    
    struct Images {
        static let userVerifiedImage = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink)
        
        static let userUnVerifiedImage = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor.systemGray)
    }
    
    //MARK: - UI
    
    lazy var profileImageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let profileImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        button.layer.masksToBounds = false
        button.isUserInteractionEnabled = true
        button.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        button.layer.cornerRadius = Metrics.profileImageButtonHeight / 2
        button.addTarget(self, action: #selector(pressedProfileImageButton(_:)), for: .touchUpInside)
        return button
    }()
    
    let cameraIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.cameraIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "로딩 중.."
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let userVerifiedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.cellId
        )
        return tableView
    }()
    
    // UIBarButtonItems
    
    lazy var myPageBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "마이페이지"
        button.style = .done
        button.tintColor = .black
        return button
    }()
    
    lazy var settingsBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        if #available(iOS 14.0, *) {
            button.image = UIImage(systemName: "gearshape")
        } else {
            button.image = UIImage(systemName: "gear")
        }
        button.style = .plain
        button.target = self
        button.action = #selector(pressedSettingsBarButtonItem)
        return button
    }()
    
    // UIImagePickerController
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    
    //MARK: - Initialization
    init(viewModel: MyPageViewModel) {
        super.init()
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        viewModel.loadUserProfile()
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.loadUserProfile()
    }
    
    
    //MARK: - UI Setup
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = myPageBarButtonItem
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        view.addSubview(profileImageContainerView)
        profileImageContainerView.addSubview(profileImageButton)
        profileImageContainerView.addSubview(cameraIcon)
        profileImageContainerView.addSubview(userNicknameLabel)
        profileImageContainerView.addSubview(userVerifiedImage)
        view.addSubview(settingsTableView)

    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        profileImageContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.left.equalTo(view.snp.left).offset(50)
            $0.right.equalTo(view.snp.right).offset(-50)
            $0.height.equalTo(160)
        }
        
        profileImageButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        userNicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        cameraIcon.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.bottom.equalTo(userNicknameLabel.snp.top).offset(-10)
            $0.right.equalTo(profileImageContainerView.snp.right).offset(-80)
        }
        
        userVerifiedImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.left.equalTo(userNicknameLabel.snp.right).offset(4)
            $0.bottom.equalTo(profileImageContainerView.snp.bottom).offset(5)
        }
        
        settingsTableView.snp.makeConstraints {
            $0.top.equalTo(profileImageContainerView.snp.bottom).offset(6)
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func configure() {
        
        createObserversForPresentingVerificationAlert()
        createObserversForGettingBadgeValue()
        
        viewModel.delegate = self
    }

}


