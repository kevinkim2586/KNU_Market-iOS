import UIKit
import Alamofire
import SPIndicator
import SwiftMessages
import SnackBar_swift

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
        navigationItem.largeTitleDisplayMode = .always
        
        viewModel.fetchItemList()
    
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)!]
        navigationController?.navigationBar.isHidden = false
    }

    
    @IBAction func pressedAddButton(_ sender: UIButton) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let itemVC: ItemViewController = segue.destination as? ItemViewController else {
            return
        }
        
        itemVC.hidesBottomBarWhenPushed = true

    }
}

//MARK: - HomeViewModelDelegate

extension HomeViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        
        SPIndicator.present(title: "\(User.shared.nickname)님",
                            message: "환영합니다",
                            preset: .custom(UIImage(systemName: "face.smiling")!))
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
    
    @objc func refreshTableView() {
        
        viewModel.itemList.removeAll()
        viewModel.needsToFetchMoreData = true
        viewModel.isPaginating = false
        viewModel.fetchItemList()
    }

    
    
}

//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
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
        
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
    
    func initializeAddButton() {
        
        addButton.layer.cornerRadius = addButton.frame.width / 2
        addButton.backgroundColor = UIColor(named: Constants.Color.appColor)

        let font = UIFont.systemFont(ofSize: 30)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let plusImage = UIImage(systemName: "plus", withConfiguration:
                                    configuration)
        addButton.setImage(plusImage, for: .normal)
    }

    
}
