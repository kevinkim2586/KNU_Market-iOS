import UIKit
import SnapKit

class ChatListViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var viewModel: ChatListViewModel!
    
    //MARK: - UI
    
    lazy var chatListTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(
            ChatListTableViewCell.self,
            forCellReuseIdentifier: ChatListTableViewCell.cellId
        )
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        return tableView
    }()
    
    lazy var chatBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "채팅"
        button.style = .done
        button.tintColor = .black
        button.target = self
        button.action = #selector(pressedChatBarButtonItem)
        return button
    }()
    
    //MARK: - Initialization
    
    init(viewModel: ChatListViewModel) {
        super.init()
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.applicationIconBadgeNumber = User.shared.chatNotificationList.count
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
        chatListTableView.refreshControl?.beginRefreshing()
        viewModel.fetchChatList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatListTableView.refreshControl?.endRefreshing()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = chatBarButtonItem
        
        view.addSubview(chatListTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        chatListTableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setNavigationBarAppearance(to: .white)
    }
    
    private func configure() {
        createObserversForGettingBadgeValue()
        viewModel.delegate = self
    }
}

//MARK: - Target Methods

extension ChatListViewController {
    
    @objc private func pressedChatBarButtonItem() {
        if viewModel.roomList.count == 0 { return }
        let topRow = IndexPath(row: 0, section: 0)
        chatListTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
}

//MARK: - ChatListViewModelDelegate

extension ChatListViewController: ChatListViewModelDelegate {
    
    func didFetchChatList() {
        chatListTableView.refreshControl?.endRefreshing()

        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
            
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
        showSimpleBottomAlertWithAction(
            message: "채팅 목록을 불러오지 못했습니다 😥",
            buttonTitle: "재시도"
        ) {
            self.chatListTableView.refreshControl?.beginRefreshing()
            self.viewModel.fetchChatList()
        }
    }
    
    func didExitPost(at indexPath: IndexPath) {
        chatListTableView.deleteRows(at: [indexPath], with: .fade)
        NotificationCenter.default.post(
            name: .updateItemList,
            object: nil
        )
    }
    
    func failedExitingPost(with error: NetworkError) {
        showSimpleBottomAlert(with: "채팅방 나가기에 실패했습니다. 나중에 다시 시도해주세요.😥")
    }
    
    func didDeleteAndExitPost(at indexPath: IndexPath) {
        chatListTableView.deleteRows(at: [indexPath], with: .fade)
        NotificationCenter.default.post(
            name: .updateItemList,
            object: nil
        )
    }
    
    func failedDeletingAndExitingPost(with error: NetworkError) {
        showSimpleBottomAlert(with: "공구 삭제 및 채팅방 나가기에 실패했습니다. 나중에 다시 시도해주세요.😥")
    }

    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.roomList.count || viewModel.roomList.count == 0 {
            return UITableViewCell()
        }
        tableView.restoreEmptyView()
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatListTableViewCell.cellId,
                for: indexPath
        ) as? ChatListTableViewCell else { return UITableViewCell() }
        
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

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func refreshTableView() {
        viewModel.fetchChatList()
    }
    
}
