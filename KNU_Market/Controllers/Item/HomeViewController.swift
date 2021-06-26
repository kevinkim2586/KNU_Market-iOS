import UIKit
import Alamofire
import SPIndicator
import SwiftMessages
import SnackBar_swift
import ViewAnimator

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
//        navigationItem.largeTitleDisplayMode = .always
    
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
//        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
              
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
//        navigationItem.largeTitleDisplayMode = .always
        
        if GlobalVariable.needsToReloadData == true {
            print("NEEDS TO RELOAD DATA")
            
            let indexPath = NSIndexPath(row: NSNotFound, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
            refreshTableView()
            GlobalVariable.needsToReloadData = false
        }
        
    }
    

    
    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        guard let uploadVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.uploadItemVC) as? UploadItemViewController else {
            fatalError()
        }
        
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
}

//MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        SPIndicator.present(title: "\(User.shared.nickname)님",
                            message: "환영합니다",
                            preset: .custom(UIImage(systemName: "face.smiling")!
                                                .withTintColor(UIColor(named: Constants.Color.appColor) ?? .systemBlue)))
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        SnackBar.make(in: self.view,
                      message: "일시적인 연결 문제가 있습니다. 🥲",
                      duration: .lengthLong).show()
    }
    
    func didFetchItemList() {
        
        print("HomeVC - didFetchItemList activated")
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
    }
    
    func failedFetchingItemList(with error: NetworkError) {
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        SnackBar.make(in: self.view,
                      message: "일시적인 연결 문제가 있습니다. 🥲",
                      duration: .lengthLong).show()
    }
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let itemVC: ItemViewController = segue.destination as? ItemViewController else { return }

        guard let index = tableView.indexPathForSelectedRow?.row else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[index].uuid
    }
    
    @objc func refreshTableView() {
         
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
    
    func createSpinnerFooter() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.frame.size.width,
                                              height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 80 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                tableView.tableFooterView = createSpinnerFooter()
                viewModel.fetchItemList()
            }
        }
    }
}

//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
        //self.navigationController?.view.backgroundColor = .white
        
        viewModel.delegate = self
    
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
    }
    
    func initializeAddButton() {
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.backgroundColor = UIColor(named: Constants.Color.appColor)

        let font = UIFont.systemFont(ofSize: 30)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let plusImage = UIImage(systemName: "plus",
                                withConfiguration: configuration)
        addButton.setImage(plusImage, for: .normal)
    }
}
