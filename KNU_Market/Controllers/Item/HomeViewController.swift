import UIKit
import Alamofire
import SwiftMessages

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)]
        navigationItem.largeTitleDisplayMode = .always
        
    
        initialize()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
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
        showSuccessCard(title: "\(User.shared.nickname)님", message: "환영합니다!", iconText: "👀")
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showErrorCard(title: "네트워크 오류", message: "일시적인 연결 문제가 있습니다. ")
    }
    
    
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("Failed to dequeue cell for ItemTableViewCell")
        }
        
        cell.configure()


    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func refreshTableView() {
        
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
        // ex
//        viewModel.reviewList.removeAll()
//        viewModel.needToFetchMoreData = true
//        viewModel.isPaginating = false
//        viewModel.fetchReviewList(of: 2)
        
    }

    
    
}

//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
        viewModel.delegate = self
    
        loadUserInfo()
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
        let plusImage = UIImage(systemName: "plus", withConfiguration: configuration)
        addButton.setImage(plusImage, for: .normal)
    }
    
    func loadUserInfo() {
        
        viewModel.loadUserProfile()
    }
    
}
