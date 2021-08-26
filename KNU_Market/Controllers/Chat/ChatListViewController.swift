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
        
        print("✏️ noti: \(User.shared.chatNotificationList)")
        
        UIApplication.shared.applicationIconBadgeNumber = User.shared.chatNotificationList.count
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        viewModel.fetchChatList()
    }
    
    @IBAction func pressedLeftBarButton(_ sender: UIBarButtonItem) {
        let topRow = IndexPath(row: 0, section: 0)
        self.chatListTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}

//MARK: - ChatListViewModelDelegate

extension ChatListViewController: ChatListViewModelDelegate {

    func didFetchChatList() {
        
        chatListTableView.refreshControl?.endRefreshing()
        
        if viewModel.roomList.count == 0 {
            chatListTableView.showEmptyView(imageName: Constants.Images.emptyChatList,
                                            text: "아직 활성화된 채팅방이 없네요!\n새로운 공구에 참여해보세요 :)")
            chatListTableView.tableFooterView = UIView(frame: .zero)
        }

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
    
    func didExitPost(at indexPath: IndexPath) {
        chatListTableView.deleteRows(at: [indexPath], with: .fade)
        NotificationCenter.default.post(name: .updateItemList,
                                        object: nil)
    }
    
    func failedExitingPost(with error: NetworkError) {
        self.showSimpleBottomAlert(with: "채팅방 나가기에 실패했습니다. 나중에 다시 시도해주세요.😥")
    }
    
    func didDeleteAndExitPost(at indexPath: IndexPath) {
        chatListTableView.deleteRows(at: [indexPath], with: .fade)
        NotificationCenter.default.post(name: .updateItemList,
                                        object: nil)
    }
    
    func failedDeletingAndExitingPost(with error: NetworkError) {
        self.showSimpleBottomAlert(with: "공구 삭제 및 채팅방 나가기에 실패했습니다. 나중에 다시 시도해주세요.😥")
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.roomList.count { return UITableViewCell() }
        if self.viewModel.roomList.count == 0 { return UITableViewCell() }

        let cellIdentifier = Constants.cellID.chatTableViewCell
        
        tableView.restoreEmptyView()
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChatTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: self.viewModel.roomList[indexPath.row])
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.roomList.count == 0 { return }
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let chatVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.chatVC) as? ChatViewController else { return }
        
        chatVC.roomUID = viewModel.roomList[indexPath.row].uuid
        chatVC.chatRoomTitle = viewModel.roomList[indexPath.row].title
        chatVC.postUploaderUID = viewModel.roomList[indexPath.row].userUID
        navigationController?.pushViewController(chatVC, animated: true)
        
        if let index = ChatNotifications.list.firstIndex(of: viewModel.roomList[indexPath.row].uuid) {
            ChatNotifications.list.remove(at: index)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            
            if viewModel.currentRoomIsUserUploaded(at: indexPath.row) {
                self.presentAlertWithCancelAction(title: "본인이 방장으로 있는 채팅방입니다.",
                                                  message: "채팅방을 나가면 공구 글이 삭제되고 모든 참여자가 채팅방에서 나가기 처리가 됩니다. 삭제하시겠습니까?") { selectedOk in
                    if selectedOk {
                        self.viewModel.deleteMyPostAndExit(at: indexPath)
                    }
                }
            } else {
                self.presentAlertWithCancelAction(title: "채팅방에서 나가시겠습니까?",
                                                  message: "'확인'을 누르시면 채팅방에서 나가기 처리됩니다.") { selectedOk in
                    if selectedOk {
                        self.viewModel.exitPost(at: indexPath)
                    }
                }
            }
        }
    }

    @objc func refreshTableView() {
        viewModel.fetchChatList()
    }
    
}



//MARK: - UI Configuration & Initialization

extension ChatListViewController {
    
    func initialize() {
        
        createObserversForGettingBadgeValue()
        viewModel.delegate = self
        
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.tabBarItem.image = UIImage(named: Constants.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
        self.navigationController?.tabBarItem.selectedImage = UIImage(named: Constants.Images.chatSelected)?.withRenderingMode(.alwaysTemplate)
        
        initializeTableView()
    }
    
    func initializeTableView() {
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.refreshControl = refreshControl

        
        refreshControl.addTarget(self,
                                 action: #selector(refreshTableView),
                                 for: .valueChanged)
    }

}
