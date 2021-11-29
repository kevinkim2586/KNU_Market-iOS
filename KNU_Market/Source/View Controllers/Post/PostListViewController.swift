import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders
import PMAlertController
import SnapKit

class PostListViewController: BaseViewController {

    //MARK: - Properties
    
    private var viewModel: PostListViewModel!
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let addPostButtonSize: CGFloat = 55
    }
    
    //MARK: - UI
    
    lazy var postListsTableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.placeholderDelegate = self
        tableView.separatorStyle = .none
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        return tableView
    }()
    
    
    lazy var logoBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "크누마켓"
        button.style = .done
        button.target = self
        button.action = #selector(pressedLogoBarButton)
        return button
    }()
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "magnifyingglass")
        button.style = .plain
        button.target = self
        button.action = #selector(pressedSearchBarButton)
        return button
    }()
    
    lazy var filterBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(named: K.Images.homeMenuIcon) ?? UIImage(systemName: "gear")
        button.style = .plain
        button.target = self
        button.action = #selector(pressedFilterBarButton)
        return button
    }()
    
    lazy var addPostButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addBounceAnimation()
        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: "plus",
            withConfiguration: configuration
        )
        button.setImage(buttonImage, for: .normal)
        button.layer.cornerRadius = Metrics.addPostButtonSize / 2
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addTarget(
            self,
            action: #selector(pressedAddPostButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    
    init(postViewModel: PostListViewModel) {
        super.init()
        self.viewModel = postViewModel
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
        super.viewWillAppear(animated)
        NotificationCenter.default.post(
            name: .getBadgeValue,
            object: nil
        )
    }
    

    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = logoBarButtonItem
        navigationItem.rightBarButtonItems = [filterBarButtonItem, searchBarButtonItem]
        
        view.addSubview(postListsTableView)
        view.addSubview(addPostButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postListsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addPostButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-20)
            $0.right.equalToSuperview().offset(-25)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    override func setupActions() {
        super.setupActions()
    }
    
    private func configure() {
        
        viewModel.delegate = self
        viewModel.loadInitialMethods()
        askForNotificationPermission()
        setBackBarButtonItemTitle()
        setNavigationBarAppearance(to: .white)
        postListsTableView.showLoadingPlaceholder()
        createObservers()
    }
}

//MARK: - Target Methods

extension PostListViewController {
    
    @objc private func pressedLogoBarButton() {
        postListsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc private func pressedSearchBarButton() {
        
        let searchVC = SearchPostsViewController(
            viewModel: SearchPostViewModel(postManager: PostManager())
        )
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc private func pressedFilterBarButton() {
        let changePostFilterAction = UIAlertAction(
            title: viewModel.filterActionTitle,
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changePostFilterOption()
        }
        
        let actionSheet = UIHelper.createActionSheet(with: [changePostFilterAction], title: "글 정렬 기준")
        present(actionSheet, animated: true)
    }

    @objc private func pressedAddPostButton() {
        
        if !detectIfVerifiedUser() {
            showSimpleBottomAlertWithAction(
                message: "학생 인증을 마치셔야 사용이 가능해요.👀",
                buttonTitle: "인증하러 가기"
            ) {
                self.presentVerifyOptionVC()
            }
            return
        }
        
        let uploadVC = UploadPostViewController(
            viewModel: UploadPostViewModel(
                postManager: PostManager(),
                mediaManager: MediaManager()
            )
        )
        
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTableView),
            name: .updatePostList,
            object: nil
        )
        createObserversForGettingBadgeValue()
        createObserversForRefreshTokenExpiration()
        createObserversForUnexpectedErrors()
    }
    
}

//MARK: - PostViewModelDelegate

extension PostListViewController: PostListViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        
        guard let defaultImage = UIImage(systemName: "checkmark.circle") else { return }
        
        SPIndicator.present(
            title: "\(User.shared.nickname)님",
            message: "환영합니다 🎉",
            preset: .custom(UIImage(systemName: "face.smiling")?.withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink, renderingMode: .alwaysOriginal) ?? defaultImage)
        )
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showSimpleBottomAlertWithAction(
            message: "사용자 정보 불러오기에 실패하였습니다. 로그아웃 후 다시 이용해 주세요.😥",
            buttonTitle: "로그아웃"
        ) {
            self.popToInitialViewController()
        }
    }
    
    func didFetchPostList() {
        postListsTableView.reloadData()
        postListsTableView.refreshControl?.endRefreshing()
        postListsTableView.tableFooterView = nil
    }
    
    func failedFetchingPostList(errorMessage: String, error: NetworkError) {
        postListsTableView.refreshControl?.endRefreshing()
        postListsTableView.tableFooterView = nil
        if error != .E601 {
            postListsTableView.showErrorPlaceholder()
        }
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource


extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.postList.count
            || viewModel.postList.count == 0 { return UITableViewCell() }
        
        let cellIdentifier = PostTableViewCell.cellId
                
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: viewModel.postList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
          
        let postVC = PostViewController(
            viewModel: PostViewModel(
                pageId: viewModel.postList[indexPath.row].uuid,
                postManager: PostManager(),
                chatManager: ChatManager()
            ),
            isFromChatVC: false
        )
        
        navigationController?.pushViewController(postVC, animated: true)
    }

    @objc func refreshTableView() {
        
        //사라지는 애니메이션 처리
        UIView.animate(
            views: postListsTableView.visibleCells,
            animations: Animations.forTableViews,
            reversed: true,
            initialAlpha: 1.0,      // 보이다가
            finalAlpha: 0.0,        // 안 보이게
            completion: {
                self.viewModel.refreshTableView()
            }
        )
    }
}

//MARK: - UIScrollViewDelegate

extension PostListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (postListsTableView.contentSize.height - 50 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                postListsTableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchPostList()
            }
        }
    }
}


//MARK: - Placeholder Delegate

extension PostListViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        postListsTableView.refreshControl?.beginRefreshing()
        self.viewModel.resetValues()
        self.viewModel.fetchPostList()
    }
}

