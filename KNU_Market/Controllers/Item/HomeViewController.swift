import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders

class HomeViewController: UIViewController {

    @IBOutlet weak var itemTableView: TableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private let refreshControl = UIRefreshControl()
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
              
    }
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        guard let uploadVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.uploadItemVC) as? UploadItemViewController else {
            return
        }
        uploadVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    @IBAction func pressedSearchButton(_ sender: UIBarButtonItem) {
        
        let searchVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.searchPostVC) as! SearchPostViewController
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func pressedLeftBarButton(_ sender: UIBarButtonItem) {
        
        let topRow = IndexPath(row: 0, section: 0)
        self.itemTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}

//MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        
        guard let defaultImage = UIImage(systemName: "checkmark.circle") else { return }
    
        SPIndicator.present(title: "\(User.shared.nickname)님",
                            message: "환영합니다 🎉",
                            preset: .custom(UIImage(systemName: "face.smiling") ?? defaultImage))
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showSimpleBottomAlertWithAction(message: "사용자 정보 불러오기에 실패하였습니다. 로그아웃 후 다시 이용해 주세요.😥",
                                        buttonTitle: "로그아웃") {
            self.popToInitialViewController()
        }
    }
  
    func didFetchItemList() {
        
        itemTableView.reloadData()
        refreshControl.endRefreshing()
        itemTableView.tableFooterView = nil
    }
    
    func failedFetchingItemList(with error: NetworkError) {
        
        refreshControl.endRefreshing()
        itemTableView.tableFooterView = nil
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        
        self.showSimpleBottomAlert(with: error.errorDescription)
    }
    
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.itemList.count { return UITableViewCell() }
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError()
        }

        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let itemVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.itemVC) as? ItemViewController else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[indexPath.row].uuid
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }

    
    @objc func refreshTableView() {
        
        //사라지는 애니메이션 처리
        UIView.animate(views: self.itemTableView.visibleCells,
                       animations: Animations.forTableViews,
                       reversed: true,
                       initialAlpha: 1.0,   // 보이다가
                       finalAlpha: 0.0,      // 안 보이게
                       completion: {
                        self.viewModel.resetValues()
                        self.viewModel.fetchItemList()
                        self.viewModel.fetchEnteredRoomInfo()
                       })
    }
}

//MARK: - UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (itemTableView.contentSize.height - 50 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                itemTableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchItemList()
            }
        }
    }
}

//MARK: - Placeholder Delegate

extension HomeViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        self.viewModel.resetValues()
        self.viewModel.fetchItemList()
    }
}

//MARK: - UITabBarControllerDelegate

extension HomeViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
     
        
    }
}

//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
        askForNotificationPermission()

        self.navigationController?.tabBarItem.image = UIImage(named: Constants.Images.homeUnselected)?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: Constants.Images.homeSelected)?.withRenderingMode(.alwaysTemplate)
        
        self.tabBarController?.delegate = self
        
        viewModel.delegate = self
        itemTableView.placeholderDelegate = self
        
        viewModel.loadInitialMethods()

        initializeTableView()
        initializeAddButton()
        initializeBarButtonItem()
        createObservers()
    }
    
    func initializeTableView() {
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.refreshControl = refreshControl
        
        let nibName = UINib(nibName: Constants.XIB.itemTableViewCell, bundle: nil)
        itemTableView.register(nibName, forCellReuseIdentifier: Constants.cellID.itemTableViewCell)
        
        refreshControl.addTarget(self,
                                 action: #selector(refreshTableView),
                                 for: .valueChanged)
        
        itemTableView.showLoadingPlaceholder()
    }
    
    func initializeAddButton() {
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.backgroundColor = UIColor(named: Constants.Color.appColor)

        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(systemName: "plus",
                                withConfiguration: configuration)
        addButton.setImage(buttonImage, for: .normal)
    }
    
    func initializeBarButtonItem() {
        
        let settingsBarButton = UIBarButtonItem(image: UIImage(named: Constants.Images.homeMenuIcon) ?? UIImage(systemName: "gear"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(pressedSettingsButton))
        
        settingsBarButton.tintColor = .black
        navigationItem.rightBarButtonItems?.insert(settingsBarButton, at: 0)
    
    }
    
    @objc func pressedSettingsButton() {
        
        let actionSheet = UIAlertController(title: "글 정렬 기준",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let title: String?
        switch viewModel.currentlySelectedFilterIndex {
        case 0:
            title = "모집 중인 공구만 보기"
        default:
            title = "모든 공구 보기"
        }
        
        guard let title = title else {
            showSimpleBottomAlert(with: "일시적인 오류입니다.😥")
            return
        }
        
        actionSheet.addAction(UIAlertAction(title: title,
                                            style: .default) { [weak self] _ in
            
            
            
        })
        actionSheet.addAction(UIAlertAction(title: "취소",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func createObservers() {
    
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshTableView),
                                               name: .updateItemList,
                                               object: nil)
        createObserversForGettingBadgeValue()
    }
}
