import UIKit
import SnapKit
import ImageSlideshow
import RxSwift

class PostViewController: BaseViewController {
    
    //MARK: - Properties
    var viewModel: PostViewModel!
    var isFromChatVC: Bool = false
    
    //MARK: - Constants
    
    private lazy var headerViewHeight = view.frame.size.height * 0.5

    //MARK: - UI
    lazy var postControlButtonView: KMPostButtonView = {
        let view = KMPostButtonView()
        view.delegate = self
        return view
    }()
        
    lazy var postHeaderView: PostHeaderView = {
        let headerView = PostHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerViewHeight),
            currentVC: self
        )
       return headerView
    }()

    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .clear
        tableView.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        tableView.refreshControl?.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        return tableView
    }()
    
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
 
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
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
        createObservers()
        configureHeaderView()
        bind()
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
    
    func createObservers() {
        
        createObserversForPresentingVerificationAlert()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPage),
            name: .didUpdatePost,
            object: nil
        )
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


