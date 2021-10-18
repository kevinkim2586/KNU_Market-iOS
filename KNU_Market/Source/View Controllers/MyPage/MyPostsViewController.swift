import UIKit
import SDWebImage
import SnapKit
import Alamofire

class MyPostsViewController: BaseViewController {

    //MARK: - Properties
    private var viewModel: HomeViewModel!
    
    //MARK: - Constants
    
    //MARK: - UI
    
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        tableView.tableFooterView = UIView(frame: .zero)
        let nibName = UINib(nibName: K.XIB.itemTableViewCell, bundle: nil)
        tableView.register(
            nibName,
            forCellReuseIdentifier: K.cellID.itemTableViewCell
        )
        return tableView
    }()
    
    //MARK: - Initialization
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupViewModel()
    }
    
    //MARK: - UI Setup
    override func setupLayout() {
        view.addSubview(postTableView)
    }
    
    override func setupConstraints() {
        
        postTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        view.backgroundColor = .white
    }
    
    private func configure() {
        title = "내가 올린 공구"
        createObserversForPresentingVerificationAlert()
    }
    
    private func setupViewModel() {
        self.viewModel = HomeViewModel(itemManager: ItemManager(), chatManager: ChatManager(), userManager: UserManager())
        self.viewModel.delegate = self
        self.viewModel.fetchItemList(fetchCurrentUsers: true)
    }
}

//MARK: - HomeViewModelDelegate

extension MyPostsViewController: HomeViewModelDelegate {
    
    func didFetchItemList() {
        postTableView.reloadData()
        postTableView.refreshControl?.endRefreshing()
        postTableView.tableFooterView = nil
        postTableView.restoreEmptyView()
        if viewModel.itemList.count == 0 {
            postTableView.showEmptyView(
                imageName: K.Images.emptyChatList,
                text: "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
            )
        }
    }
    
    func failedFetchingItemList(errorMessage: String, error: NetworkError) {
        if viewModel.itemList.count == 0 {
            postTableView.showEmptyView(
                imageName: K.Images.emptyChatList,
                text: errorMessage
            )
        }
        postTableView.refreshControl?.endRefreshing()
        postTableView.reloadData()
        postTableView.tableFooterView = nil
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.itemList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = K.cellID.itemTableViewCell

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: StoryboardName.ItemList, bundle: nil)
        
        guard let postVC = storyboard.instantiateViewController(
            withIdentifier: K.StoryboardID.itemVC
        ) as? ItemViewController else { return }
        
        postVC.hidesBottomBarWhenPushed = true
        postVC.pageID = viewModel.itemList[indexPath.row].uuid
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc private func refreshTableView() {
        UIView.animate(
            views: self.postTableView.visibleCells,
            animations: Animations.forTableViews,
            reversed: true,
            initialAlpha: 1.0,   // 보이다가
            finalAlpha: 0.0,     // 안 보이게
            completion: {
                self.viewModel.resetValues()
                self.viewModel.fetchItemList(fetchCurrentUsers: true)
            }
        )
    }
    
    
}

//MARK: - UIScrollViewDelegate

extension MyPostsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (postTableView.contentSize.height - 80 - scrollView.frame.size.height) {
            if !viewModel.isFetchingData {
                postTableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchItemList(fetchCurrentUsers: true)
            }
        }
    }
}


