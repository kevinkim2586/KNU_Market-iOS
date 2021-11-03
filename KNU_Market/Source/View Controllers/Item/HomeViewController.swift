import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders
import PMAlertController

class HomeViewController: UIViewController {

    @IBOutlet weak var itemTableView: TableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    private var viewModel = HomeViewModel(itemManager: ItemManager(), chatManager: ChatManager(), userManager: UserManager(), popupManager: PopupManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(
            name: .getBadgeValue,
            object: nil
        )

    }
    
 
}

//MARK: - Methods

extension HomeViewController {
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        if !detectIfVerifiedUser() {
            showSimpleBottomAlertWithAction(
                message: "학생 인증을 마치셔야 사용이 가능해요.👀",
                buttonTitle: "인증하러 가기"
            ) {
                self.presentVerifyOptionVC()
            }
            return
        }
        guard let uploadVC = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.uploadItemVC
        ) as? UploadItemViewController else { return }
        uploadVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    @IBAction func pressedSearchButton(_ sender: UIBarButtonItem) {
        
        let searchVC = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.searchPostVC
        ) as! SearchPostViewController
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func pressedLeftBarButton(_ sender: UIBarButtonItem) {
        let topRow = IndexPath(row: 0, section: 0)
        itemTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}

//MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        UIHelper.presentWelcomePopOver(nickname: User.shared.nickname)
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showSimpleBottomAlertWithAction(
            message: "사용자 정보 불러오기에 실패하였습니다. 로그아웃 후 다시 이용해 주세요.😥",
            buttonTitle: "로그아웃"
        ) {
            self.popToInitialViewController()
        }
    }
    
    func didFetchItemList() {
        itemTableView.reloadData()
        itemTableView.refreshControl?.endRefreshing()
        itemTableView.tableFooterView = nil
    }
    
    func failedFetchingItemList(errorMessage: String, error: NetworkError) {
        itemTableView.refreshControl?.endRefreshing()
        itemTableView.tableFooterView = nil
        if error != .E601 {
            itemTableView.showErrorPlaceholder()
        }
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didFetchLatestPopup(model: PopupModel) {
        print("✏️ didFetchLatestPopup Activated")
        let popupVC = KMPopupViewController(popupManager: PopupManager(), imagePath: model.imagePath, landingUrl: model.landingUrl)
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true)
    }
    
    func failedFetchingLatestPopup(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
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
        
        if indexPath.row > viewModel.itemList.count
            || viewModel.itemList.count == 0 { return UITableViewCell() }
        
        let cellIdentifier = K.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? ItemTableViewCell else { return UITableViewCell() }

        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let itemVC = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.itemVC
        ) as? ItemViewController else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[indexPath.row].uuid
        
        navigationController?.pushViewController(itemVC, animated: true)
    }

    
    @objc func refreshTableView() {
        
        //사라지는 애니메이션 처리
        UIView.animate(
            views: itemTableView.visibleCells,
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
        itemTableView.refreshControl?.beginRefreshing()
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
        tabBarController?.delegate = self
        viewModel.delegate = self
        itemTableView.placeholderDelegate = self

        viewModel.loadInitialMethods()
        
        askForNotificationPermission()
        initializeTableView()
        initializeAddButton()
        initializeBarButtonItem()
        createObservers()
        setBackBarButtonItemTitle()
        setNavigationBarAppearance(to: .white)
        
        
        if !User.shared.isNotFirstAppLaunch {
            presentInitialVerificationAlert()
        }
    }
    

    
    func initializeTableView() {
        
        itemTableView.delegate = self
        itemTableView.dataSource = self
        itemTableView.refreshControl = UIRefreshControl()
    
        
        let nibName = UINib(
            nibName: K.XIB.itemTableViewCell,
            bundle: nil
        )
        itemTableView.register(
            nibName,
            forCellReuseIdentifier: K.cellID.itemTableViewCell
        )
        itemTableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        
        itemTableView.showLoadingPlaceholder()
    }
    
    func initializeAddButton() {
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.backgroundColor = UIColor(named: K.Color.appColor)
        
        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: "plus",
            withConfiguration: configuration
        )
        addButton.setImage(buttonImage, for: .normal)
    }
    
    func initializeBarButtonItem() {
        
        let settingsBarButton = UIBarButtonItem(
            image: UIImage(named: K.Images.homeMenuIcon) ?? UIImage(systemName: "gear"),
            style: .plain,
            target: self,
            action: #selector(pressedSettingsButton)
        )
        
        settingsBarButton.tintColor = .black
        navigationItem.rightBarButtonItems?.insert(settingsBarButton, at: 0)
        
    }
    
    @objc func pressedSettingsButton() {
        
        let actionSheet = UIAlertController(
            title: "글 정렬 기준",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let title = viewModel.filterActionTitle

        actionSheet.addAction(UIAlertAction(title: title,
                                            style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changePostFilterOption()
        })
        actionSheet.addAction(UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil)
        )
        
        present(actionSheet, animated: true)
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTableView),
            name: .updateItemList,
            object: nil
        )
        createObserversForGettingBadgeValue()
        createObserversForRefreshTokenExpiration()
        createObserversForUnexpectedErrors()
    }
    

}
