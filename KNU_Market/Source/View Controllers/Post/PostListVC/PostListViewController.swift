import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class PostListViewController: BaseViewController, View {

    typealias Reactor = PostListViewReactor
    
    //MARK: - Constants
    
    struct Metrics {
        static let addPostButtonSize = 55.f
    }
    
    //MARK: - UI
    
    let postListsTableView = UITableView().then {
        $0.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
    }
    
    let refreshControl = UIRefreshControl()

    let logoBarButtonItem = UIBarButtonItem().then {
        $0.title = "크누마켓"
        $0.style = .done
    }
    
    let uploadPostButton = UIButton().then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.addBounceAnimation()
        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: "plus",
            withConfiguration: configuration
        )
        $0.tintColor = .white
        $0.setImage(buttonImage, for: .normal)
        $0.layer.cornerRadius = Metrics.addPostButtonSize / 2
        $0.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
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
        
        navigationItem.leftBarButtonItem = logoBarButtonItem
        
//        if let tabBar = self.tabBarController?.tabBar {
//            
//            tabBar.layer.cornerRadius = 30
//            tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
////            tabBar.layer.masksToBounds = true
//            tabBar.layer.shadowColor = UIColor.lightGray.cgColor
//            tabBar.layer.shadowOpacity = 0.5
//            tabBar.layer.shadowOffset = CGSize.zero
//            tabBar.layer.shadowRadius = 5
//            tabBar.layer.borderColor = UIColor.clear.cgColor
//            tabBar.layer.borderWidth = 0
//            tabBar.clipsToBounds = false
//            tabBar.backgroundColor = UIColor.white
//            UITabBar.appearance().shadowImage = UIImage()
//            UITabBar.appearance().backgroundImage = UIImage()
//        }
        

        
        view.addSubview(postListsTableView)
        view.addSubview(uploadPostButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
                
        postListsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        uploadPostButton.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.addPostButtonSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.right.equalToSuperview().offset(-25)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: PostListViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.loadInitialMethods }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refreshTableView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        logoBarButtonItem.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postListsTableView.scrollToRow(
                    at: IndexPath(row: 0, section: 0),
                    at: .top,
                    animated: true
                )
            })
            .disposed(by: disposeBag)
        
        uploadPostButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                if reactor.currentState.isUserVerified {
                    let uploadVC = UploadPostViewController(
                        viewModel: UploadPostViewModel(
                            postManager: PostManager(),
                            mediaManager: MediaManager()
                        )
                    )
                    self.navigationController?.pushViewController(
                        uploadVC,
                        animated: true
                    )
                    
                } else {
                    self.showSimpleBottomAlertWithAction(
                        message: "학생 인증을 마치셔야 사용이 가능해요.👀",
                        buttonTitle: "인증하러 가기"
                    ) {
                        self.presentVerifyOptionVC()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        postListsTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        // Output
        
        reactor.state
            .map { $0.userNickname }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .subscribe(onNext: { nickname in
                UIHelper.presentWelcomePopOver(nickname: nickname!)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.postList }
            .bind(to: postListsTableView.rx.items(
                cellIdentifier: PostTableViewCell.cellId,
                cellType: PostTableViewCell.self)
            ) { indexPath, postList, cell in
                cell.configure(with: postList)
            }
            .disposed(by: disposeBag)
        
        postListsTableView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (_, indexPath) in
                self.postListsTableView.deselectRow(at: indexPath, animated: true)
                
                let postUUID = reactor.currentState.postList[indexPath.row].uuid
                let postVC = PostViewController(
                    reactor: PostViewReactor(
                        pageId: postUUID,
                        isFromChatVC: false,
                        postService: PostService(network: Network<PostAPI>(plugins: [AuthPlugin()])),
                        chatService: ChatService(
                            network: Network<ChatAPI>(plugins: [AuthPlugin()]),
                            userDefaultsGenericService: UserDefaultsGenericService()
                        ),
                        userDefaultsService: UserDefaultsGenericService()
                    )
                )
                self.navigationController?.pushViewController(postVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        postListsTableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.postListsTableView.frame.height > 0 else { return false }
                return offset.y + self.postListsTableView.frame.height >= self.postListsTableView.contentSize.height - 100
            }
            .filter { _ in reactor.currentState.isFetchingData == false }
            .map { _ in Reactor.Action.fetchPostList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isFetchingData }
            .withUnretained(self)
            .subscribe(onNext: { (_, isFetchingData) in
                self.postListsTableView.tableFooterView = isFetchingData
                ? UIHelper.createSpinnerFooterView(in: self.view)
                : nil
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshingData }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAllowedToUploadPost }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, isAllowed) in
                
                if isAllowed! {
                    let uploadVC = UploadPostViewController(
                        viewModel: UploadPostViewModel(
                            postManager: PostManager(),
                            mediaManager: MediaManager()
                        )
                    )
                    self.navigationController?.pushViewController(uploadVC, animated: true)
                    
                } else {
                    self.showSimpleBottomAlertWithAction(
                        message: "학생 인증을 마치셔야 사용이 가능해요.👀",
                        buttonTitle: "인증하러 가기"
                    ) {
                        self.presentVerifyOptionVC()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.needsToShowPopup }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                if let model = reactor.currentState.popupModel {
                    let popupVC = PopupViewController(
                        reactor: PopupReactor(
                            popupUid: model.popupUid,
                            mediaUid: model.mediaUid,
                            landingUrlString: model.landingUrl,
                            popupService: PopupService(network: Network<PopupAPI>())
                        )
                    )
                    popupVC.modalPresentationStyle = .overFullScreen
                    popupVC.modalTransitionStyle = .crossDissolve
                    self.present(popupVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, errorMessage) in
                self.showSimpleBottomAlert(with: errorMessage!)
            })
            .disposed(by: disposeBag)
        
        // Notification Center
        
        NotificationCenterService.updatePostList.addObserver()
            .map { _ in Reactor.Action.refreshTableView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationCenterService.configureChatTabBadgeCount.addObserver()
            .bind { _ in
                self.configureChatTabBadgeCount()
            }
            .disposed(by: disposeBag)
        
        NotificationCenterService.unexpectedError.addObserver()
            .bind { _ in
                self.presentUnexpectedError()
            }
            .disposed(by: disposeBag)
    }
    
    private func configure() {
        postListsTableView.refreshControl = refreshControl
    }
}

