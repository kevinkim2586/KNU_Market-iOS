import UIKit
import SPIndicator
import SwiftMessages
import SnackBar_swift
import ViewAnimator
import HGPlaceholders

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var addButton: UIButton!
  
    private let refreshControl = UIRefreshControl()
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        initialize()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
              
        if Settings.needsToReloadData == true {
            print("NEEDS TO RELOAD DATA")
            
            let indexPath = NSIndexPath(row: NSNotFound, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath,
                                       at: .top,
                                       animated: false)
            refreshTableView()
            Settings.needsToReloadData = false
        }
        
    }
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        guard let uploadVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.uploadItemVC) as? UploadItemViewController else {
            return
        }
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
}

//MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        
        SPIndicator.present(title: "\(User.shared.nickname)님",
                            message: "환영합니다 🎉",
                            preset: .custom(UIImage(systemName: "face.smiling")!))
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
  
    func didFetchItemList() {
        
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
    }
    
    func failedFetchingItemList(with error: NetworkError) {
        tableView.showErrorPlaceholder()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        self.showSimpleBottomAlert(with: "일시적인 연결 문제가 있습니다. 🥲")
    }
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 아래 코드 더 수정 고민
        if indexPath.row > viewModel.itemList.count - 1 {
            print("❗️ Index Out Of Range -- indexPathRow: \(indexPath.row), reviewList count: \(viewModel.itemList.count)")
            return UITableViewCell()
        }
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let itemVC: ItemViewController = segue.destination as? ItemViewController else { return }

        guard let index = tableView.indexPathForSelectedRow?.row else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[index].uuid
    }
    
    @objc func refreshTableView() {
        
        //tableView.showLoadingPlaceholder()
//        self.viewModel.resetValues()
//        self.viewModel.fetchItemList()
        
        //사라지는 애니메이션 처리
        UIView.animate(views: self.tableView.visibleCells,
                       animations: Animations.forTableViews,
                       reversed: true,
                       initialAlpha: 1.0,   // 보이다가
                       finalAlpha: 0.0,      // 안 보이게
                       completion: {
                        self.viewModel.resetValues()
                        self.viewModel.fetchItemList()
                       })
    }
}

//MARK: - UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 80 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                tableView.tableFooterView = createSpinnerFooterView()
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

//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
        self.navigationController?.tabBarItem.image = UIImage(named: Constants.Images.homeUnselected)?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: Constants.Images.homeSelected)?.withRenderingMode(.alwaysOriginal)
        
        viewModel.delegate = self
        tableView.placeholderDelegate = self
    
        viewModel.loadUserProfile()
        viewModel.fetchItemList()
        
        initializeTableView()
        initializeAddButton()
    }
    
    func initializeTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self,
                                 action: #selector(refreshTableView),
                                 for: .valueChanged)
        
        tableView.showLoadingPlaceholder()
    }
    
//    func initializeBarButtonItem(with image: UIImage = UIImage(named: Constants.Images.defaultProfileImage)!) {
//
//        let scaledImage = image.resizeImage(size: CGSize(width: 26, height: 26))
//        let imageView = UIImageView(image: scaledImage)
//        imageView.frame = CGRect(origin: .zero, size: scaledImage.size)
//        imageView.layer.cornerRadius = imageView.frame.size.width / 2
//        imageView.clipsToBounds = true
//
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageView)
//    }
    
    func initializeAddButton() {
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.backgroundColor = UIColor(named: Constants.Color.appColor)

        let font = UIFont.systemFont(ofSize: 20)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(systemName: "pencil",
                                withConfiguration: configuration)
        addButton.setImage(buttonImage, for: .normal)
    }
}
