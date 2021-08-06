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
    
    func didExitPost() {
        
    }
    
    func failedExitingPost(with error: NetworkError) {
        
    }
    
    func didDeleteAndExitPost() {
        
    }
    
    func failedDeletingAndExitingPost(with error: NetworkError) {
        
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.roomList.count { return UITableViewCell() }
        
        let cellIdentifier = Constants.cellID.chatTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: self.viewModel.roomList[indexPath.row])
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.chatVC) as? ChatViewController else { return }
        
        chatVC.room = viewModel.roomList[indexPath.row].uuid
        chatVC.chatRoomTitle = viewModel.roomList[indexPath.row].title
        chatVC.postUploaderUID = viewModel.roomList[indexPath.row].userUID
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if viewModel.currentRoomIsUserUploaded(at: indexPath.row) {
                
                print("✏️ currentRoomIsUserUploaded - TRUE")
                
                // TODO: - 수정 필요
                //deleteAndExitPost()
                
                
            } else {
                
                print("✏️ currentRoomIsUserUploaded - FALSE")
                // exitPost
                
            }
    
            
            
            
            
            self.presentAlertWithCancelAction(title: "정말 채팅방을 나가시겠습니까?",
                                              message: "채팅방을 나가면 대화 내용이 삭제되며 공구에서 나가기 처리됩니다.") { selectedOk in
                
                if selectedOk {
                    
                    self.viewModel.exitPost(at: indexPath.row) { result in
                        
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        case .failure(let error):
                            self.showSimpleBottomAlert(with: error.errorDescription)
                        }
                    }
                }
            }
        }
    }
    
    func deleteCell(at indexPath: IndexPath) {
        
        
    }

    
    @objc func refreshTableView() {
        viewModel.fetchChatList()
    }
    
}



//MARK: - UI Configuration & Initialization

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
