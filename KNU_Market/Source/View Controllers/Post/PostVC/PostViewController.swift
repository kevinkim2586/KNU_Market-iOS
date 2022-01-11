import UIKit
import SnapKit
import ImageSlideshow
import RxSwift
import RxCocoa
import ReactorKit

class PostViewController: BaseViewController, View {
    
    typealias Reactor = PostViewReactor
    
    //MARK: - Properties
    var viewModel: PostViewModel!
    var isFromChatVC: Bool = false
    
    //MARK: - Constants
    
    private lazy var headerViewHeight = view.frame.size.height * 0.5

    //MARK: - UI
    
    let postControlButtonView = KMPostButtonView()
    
    lazy var postHeaderView = PostHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerViewHeight))
    
    
//    lazy var postControlButtonView: KMPostButtonView = {
//        let view = KMPostButtonView()
//        view.delegate = self
//        return view
//    }()
//
//    lazy var postHeaderView: PostHeaderView = {
//        let headerView = PostHeaderView(
//            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerViewHeight),
//            currentVC: self
//        )
//       return headerView
//    }()

    let postTableView = UITableView().then {
//        tableView.delegate = self
//        tableView.dataSource = self
        $0.separatorColor = .clear
        $0.separatorStyle = .none
        $0.allowsSelection = true
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl?.tintColor = .clear
        $0.register(PostCell.self, forCellReuseIdentifier: PostCell.cellId)
//        tableView.refreshControl?.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
    }
    
    let refreshControl = UIRefreshControl().then {
        $0.tintColor = .clear
    }
    
    lazy var postBottomView: KMPostBottomView = {
        let view = KMPostBottomView()
        view.delegate = self
        return view
    }()
    
    
    //MARK: - Initialization
    
    init(viewModel: PostViewModel, isFromChatVC: Bool = false) {
        super.init()
        self.viewModel = viewModel
        self.viewModel.delegate = self
        self.isFromChatVC = isFromChatVC
        hidesBottomBarWhenPushed = true
    }
    
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
        
        postTableView.refreshControl = refreshControl
        
        view.addSubview(postTableView)
        view.addSubview(postControlButtonView)
        view.addSubview(postBottomView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
        postBottomView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        postTableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(postBottomView.snp.top).offset(0)
        }
    }
    
    
    private func configure() {
        loadInitialMethods()
        configureHeaderView()
        bind()
    }
    
    
    //MARK: - Binding
    
    func bind(reactor: PostViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            .disposed(by: disposeBag)

        
        postTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refreshPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        postControlButtonView.backButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        

        postControlButtonView.trashButton.rx.tap
            .withUnretained(self)
            .flatMap {  _ in
                self.presentPostDeleteActionSheet()
            }
            .map { actionType -> Observable<ActionType> in
                switch actionType {
                case .ok:
                    return self.presentAlertWithConfirmation(
                        title: "정말 삭제하시겠습니까?",
                        message: nil
                    )
                case .cancel:
                    return .empty()
                }
            }
            .flatMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (_, actionType) in
                switch actionType {
                case .ok:
                    self.reactor?.action.onNext(.deletePost)
                case .cancel:
                    break
                }
            })
            .disposed(by: disposeBag)
        

        
        
        // Output
        
        reactor.state
            .map { $0.postModel }
            .filter { $0 != nil }
            .subscribe(onNext: { postModel in
                
                
                
//                self.reactor?.action.onNext(.updatePostControlButtonView)
//                self.reactor?.action.onNext(.updatePostHeaderView)
//                self.reactor?.action.onNext(.updatePostBottomView)
//
            })
            .disposed(by: disposeBag)

        

        
        // Notification Center
        
        NotificationCenterService.presentVerificationNeededAlert.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.presentUserVerificationNeededAlert()
            }
            .disposed(by: disposeBag)
        
        NotificationCenterService.didUpdatePost.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.reactor?.action.onNext(.refreshPage)
            }
            .disposed(by: disposeBag)
        
        

    }


    private func bind() {
        linkOnClicked.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.presentSafariView(with: $0)
            }).disposed(by: disposeBag)
    }
    
    private func loadInitialMethods() {
        viewModel.fetchPostDetails()
        viewModel.fetchEnteredRoomInfo()
    }

    private func configureHeaderView() {
        postTableView.tableHeaderView = nil
        postTableView.addSubview(postHeaderView)
        postTableView.contentInset = UIEdgeInsets(
            top: headerViewHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
        postTableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
        updateHeaderViewStyle()
    }
    
    
    func updateHeaderViewStyle() {
        
        var headerRect = CGRect(
            x: 0,
            y: -headerViewHeight,
            width: postTableView.bounds.width,
            height: headerViewHeight
        )
        if postTableView.contentOffset.y < -headerViewHeight {
            headerRect.origin.y = postTableView.contentOffset.y
            headerRect.size.height = -postTableView.contentOffset.y
        }
        postHeaderView.frame = headerRect
    }
    

}

//MARK: - Target Methods

extension PostViewController {
    

    @objc func refreshPage() {
        postTableView.refreshControl?.endRefreshing()
        viewModel.fetchPostDetails()
    }
    
    func presentActionSheet(with actions: [UIAlertAction], title: String?) {
        let actionSheet = UIHelper.createActionSheet(with: actions, title: title)
        present(actionSheet, animated: true)
    }
}

//MARK: - Data Configuration

extension PostViewController {
    
    func updatePostInformation() {
        updatePostControlButtonView()
        updatePostHeaderView()
        updatePostBottomView()
        postTableView.reloadData()
    }
    
    private func updatePostControlButtonView() {
        
        postControlButtonView.configure(
            isPostUserUploaded: viewModel.postIsUserUploaded,
            isCompletelyDone: viewModel.isCompletelyDone
        )
    }
    
    private func updatePostHeaderView() {
        
        postHeaderView.configure(
            imageSources: viewModel.imageSources,
            postTitle: viewModel.model?.title ?? "로딩 중..",
            profileImageUid: viewModel.model?.profileImageUID ?? "",
            userNickname: viewModel.model?.nickname ?? "-",
            locationName: viewModel.location,
            dateString: viewModel.date,
            viewCount: viewModel.viewCount
        )
        updateHeaderViewStyle()
    }
    
    private func updatePostBottomView() {
        
        postBottomView.updateData(
            isPostCompletelyDone: viewModel.isCompletelyDone,
            currentCount: viewModel.currentlyGatheredPeople,
            totalCount: viewModel.totalGatheringPeople,
            enableChatEnterButton: viewModel.shouldEnableChatEntrance
        )
    }
}


