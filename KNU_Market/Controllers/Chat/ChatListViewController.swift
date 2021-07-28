import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private let viewModel = ChatListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchChatList()
    }
    
}
//MARK: - ChatListViewModelDelegate

extension ChatListViewController: ChatListViewModelDelegate {
    
    func didFetchChatList() {
     
        chatListTableView.refreshControl?.endRefreshing()
        chatListTableView.reloadData()
    }
    
    func failedFetchingChatList(with error: NetworkError) {
        
        chatListTableView.refreshControl?.endRefreshing()
        showSimpleBottomAlertWithAction(message: "채팅 목록을 불러오지 못했습니다 😥",
                                        buttonTitle: "재시도") {
            self.chatListTableView.refreshControl?.beginRefreshing()
            self.viewModel.fetchChatList()
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.roomList.count { return UITableViewCell() }
        
        let cellIdentifier = Constants.cellID.chatTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChatTableViewCell else {
            fatalError()
        }
        
        cell.chatImageView.image = UIImage(named: "chat_bubble_icon")
        cell.chatTitleLabel.text = "공차 시키실 분?"
        cell.chatParticipatingCountLabel.text = "2" + " 명"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    @objc func refreshTableView() {
        
        viewModel.fetchChatList()
    }
    
}



//MARK: - UI Configuration

extension ChatListViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.tabBarItem.image = UIImage(named: Constants.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: Constants.Images.chatSelected)?.withRenderingMode(.alwaysOriginal)
        
        initializeTableView()
    }
    
    func initializeTableView() {
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }
}
