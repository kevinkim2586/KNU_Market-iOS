import UIKit
import SDWebImage
import HGPlaceholders

class MyPostsViewController: UIViewController {
    
    @IBOutlet var tableView: TableView!
    
    private let refreshControl = UIRefreshControl()
    private var selectedIndex: Int?
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

//MARK: - HomeViewModelDelegate

extension MyPostsViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        //
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        //
    }
    
    func didFetchUserProfileImage() {
        //
    }
    
    func didFetchItemList() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingItemList(with error: NetworkError) {
        
        tableView.showNoResultsPlaceholder()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        //
    }
    
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension MyPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath.row
        
        performSegue(withIdentifier: Constants.SegueID.goToItemVCFromMyPosts, sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let itemVC: ItemViewController = segue.destination as? ItemViewController else { return }
        guard let index = selectedIndex else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[index].uuid
    }
    
    @objc func refreshTableView() {
    
        UIView.animate(views: self.tableView.visibleCells,
                       animations: Animations.forTableViews,
                       reversed: true,
                       initialAlpha: 1.0,   // 보이다가
                       finalAlpha: 0.0,      // 안 보이게
                       completion: {
                        self.viewModel.resetValues()
                        self.viewModel.fetchItemList(fetchCurrentUsers: true)
                       })
    }
}


//MARK: - UIScrollViewDelegate

extension MyPostsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 80 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                tableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchItemList(fetchCurrentUsers: true)
            }
        }
    }
}

//MARK: - Initialization & UI Configuration 

extension MyPostsViewController {
    
    func initialize() {
        
        createObservers()
        viewModel.delegate = self
        viewModel.fetchItemList(fetchCurrentUsers: true)
        initializeTableView()
        

    }
    
    func initializeTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self

        
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView(frame: .zero)
        
        let nibName = UINib(nibName: Constants.XIB.itemTableViewCell, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: Constants.cellID.itemTableViewCell)
        
        refreshControl.addTarget(self,
                                 action: #selector(refreshTableView),
                                 for: .valueChanged)
    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentVerifyEmailVC), name: Notification.Name.presentVerifyEmailVC, object: nil)
    }
}
