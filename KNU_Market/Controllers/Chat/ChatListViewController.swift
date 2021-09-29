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
        
        UIApplication.shared.applicationIconBadgeNumber = User.shared.chatNotificationList.count
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        refreshControl.beginRefreshing()
        viewModel.fetchChatList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refreshControl.endRefreshing()
    }
    
    @IBAction func pressedLeftBarButton(_ sender: UIBarButtonItem) {
        if viewModel.roomList.count == 0 { return }
        let topRow = IndexPath(row: 0, section: 0)
        self.chatListTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}

//MARK: - ChatListViewModelDelegate

extension ChatListViewController: ChatListViewModelDelegate {

    func didFetchChatList() {
        refreshControl.endRefreshing()
        
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        
        chatListTableView.refreshControl?.endRefreshing()
        
        if viewModel.roomList.count == 0 {
            chatListTableView.showEmptyView(
                imageName: K.Images.emptyChatList,
                text: "아직 활성화된 채팅방이 없네요!\n새로운 공구에 참여해보세요 :)"
            )
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

        let cellIdentifier = K.cellID.chatTableViewCell
        
        tableView.restoreEmptyView()
        
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath
        ) as? ChatTableViewCell else {
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
        guard let chatVC = storyboard.instantiateViewController(identifier: K.StoryboardID.chatVC) as? ChatViewController else { return }
        
        chatVC.roomUID = viewModel.roomList[indexPath.row].uuid
        chatVC.chatRoomTitle = viewModel.roomList[indexPath.row].title
        chatVC.postUploaderUID = viewModel.roomList[indexPath.row].userUID
        navigationController?.pushViewController(chatVC, animated: true)
        
        if let index = ChatNotifications.list.firstIndex(of: viewModel.roomList[indexPath.row].uuid) {
            ChatNotifications.list.remove(at: index)
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
        initializeTabBarIcon()
        initializeTableView()
        setClearNavigationBarBackground()
        setNavigationBarAppearance(to: .white)
    }
    
    func initializeTabBarIcon() {
        navigationController?.tabBarItem.image = UIImage(named: K.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
        navigationController?.tabBarItem.selectedImage = UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate)
    }
    
    func initializeTableView() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.refreshControl = refreshControl
        chatListTableView.tableFooterView = UIView(frame: .zero)
        chatListTableView.separatorStyle = .none
        chatListTableView.separatorColor = .clear
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
    }

}
