import UIKit
import Photos
import SDWebImage
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import ReusableKit

class MyPageViewController: BaseViewController, View {
    
    typealias Reactor = MyPageViewReactor
    
    //MARK: - Properties
    
    var viewModel: MyPageViewModel!
    
    let dataSource = RxTableViewSectionedReloadDataSource<MyPageSectionModel>(
        configureCell: { dataSource, tableView, indexPath, item in
            let cell: MyPageTableViewCell = tableView.dequeue(Reusable.myPageCell, for: indexPath)
            
            #warning("isReportChecked 도 구현")
            if indexPath.section == 1, indexPath.row == 0 {     // 크누마켓 자체 로고가 들어가야해서 특수 케이스
                cell.leftImageView.image = UIImage(named: item.leftImageName)
            } else {
                cell.leftImageView.image = UIImage(systemName: item.leftImageName)
            }
            cell.settingsTitleLabel.text = item.title
            cell.notificationBadgeImageView.isHidden = item.isNotificationBadgeHidden
            return cell
        },
        titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].header
        }
    )
    
    //MARK: - Constants
    
    struct Reusable {
        static let myPageCell = ReusableCell<MyPageTableViewCell>()
    }
    
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
    
    let profileImageContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let profileImageButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        $0.layer.masksToBounds = false
        $0.isUserInteractionEnabled = true
        $0.contentMode = .scaleAspectFit
        $0.widthAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        $0.heightAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        $0.layer.cornerRadius = Metrics.profileImageButtonHeight / 2
    }
    
    let cameraIcon = UIImageView().then {
        $0.image = UIImage(named: K.Images.cameraIcon)
        $0.contentMode = .scaleAspectFit
    }
    
    let userNicknameLabel = UILabel().then {
        $0.text = "로딩 중.."
        $0.numberOfLines = 2
        $0.minimumScaleFactor = 0.8
        $0.adjustsFontSizeToFitWidth = true
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    let userVerifiedImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    //수정
    let settingsTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.register(Reusable.myPageCell)
    }
    
    // UIBarButtonItems
    
    //수정
    lazy var myPageBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "마이페이지"
        button.style = .done
        button.tintColor = .black
        return button
    }()
    
    //수정
    let settingsBarButtonItem = UIBarButtonItem().then {
        if #available(iOS 14.0, *) {
            $0.image = UIImage(systemName: "gearshape")
        } else {
            $0.image = UIImage(systemName: "gear")
        }
    }
    
    // UIImagePickerController
    
    //아래 삭제 검토
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    
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
        configure()
    
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
    
    //MARK: - Binding
    
    func bind(reactor: MyPageViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewDidAppear
            .map { _ in Reactor.Action.viewDidAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        settingsBarButtonItem.rx.tap
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let vc = AccountManagementViewController(userDefaultsGenericService: UserDefaultsGenericService.shared)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
    
        
//        profileImageButton.rx.tap
//            .flatMap { [unowned self] in
//                self.presentChangeProfileImageOptionsActionSheet()
//            }
//            .map { changeProfileImageType -> Any in
//
//                switch changeProfileImageType {
//                case .selectFromLibrary:
//                    return 1
//                case .remove:
//                    return ""
//                default: return ""
//                }
//            }
        
        settingsTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        settingsTableView.rx.itemSelected
            .map { Reactor.Action.cellSelected($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        // Output
        
        reactor.state
            .map { $0.myPageSectionModels }
            .bind(to: settingsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedCellIndexPath }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, indexPath) in
                self.pushViewController(indexPath: indexPath!)
                self.settingsTableView.deselectRow(at: indexPath!, animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { ($0.profileImageUid, $0.profileImageUrlString) }
            .distinctUntilChanged { $0.0 }
            .withUnretained(self)
            .subscribe(onNext: { (_, info) in
  
                if info.0 == "default" {
                    self.profileImageButton.sd_setImage(
                        with: nil,
                        for: .normal,
                        placeholderImage: UIImage(named: K.Images.pickProfileImage),
                        options: .continueInBackground
                    )
                } else {
                    
                    self.profileImageButton.sd_setImage(
                        with: URL(string: info.1),
                        for: .normal,
                        placeholderImage: UIImage(named: K.Images.pickProfileImage),
                        options: .continueInBackground
                    )
                }

            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.userNickname, $0.userId) }
            .withUnretained(self)
            .subscribe(onNext: { (_, userInfo) in
                self.userNicknameLabel.text =  "\(userInfo.0)\n(\(userInfo.1))"
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isVerified }
            .withUnretained(self)
            .subscribe(onNext: { (_, isVerified) in
                self.userVerifiedImage.image = isVerified ? Images.userVerifiedImage : Images.userUnVerifiedImage
            })
            .disposed(by: disposeBag)
    
        reactor.state
            .map { $0.alertMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, alertMessage) in
                self.showSimpleBottomAlert(with: alertMessage!)
            }
            .disposed(by: disposeBag)
    }
    
    private func configure() {
        
        createObserversForPresentingVerificationAlert()
        createObserversForGettingBadgeValue()
    }
}

extension MyPageViewController {
    
    func pushViewController(indexPath: IndexPath) {
        var vc: UIViewController?
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                vc = MyPostsViewController(viewModel: PostListViewModel(postManager: PostManager(), chatManager: ChatManager(), userManager: UserManager(), popupService: PopupService(network: Network<PopupAPI>())))
            case 1:
                vc = AccountManagementViewController(userDefaultsGenericService: UserDefaultsGenericService.shared)
            case 2:
                vc = VerifyOptionViewController()
            default: break
            }
            
        case 1:
            switch indexPath.row {
            case 0:
                vc = SendUsMessageViewController(reactor: SendUsMessageReactor())
            case 1:
                let url = URL(string: K.URL.termsAndConditionNotionURL)!
                presentSafariView(with: url)
            case 2:
                let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
                presentSafariView(with: url)
            case 3:
                vc = DeveloperInformationViewController()
            default: break
            }
        default: break
        }
        if let vc = vc {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


