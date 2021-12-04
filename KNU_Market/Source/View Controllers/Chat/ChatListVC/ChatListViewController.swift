import UIKit
import SnapKit

class ChatListViewController: BaseViewController {
    
    //MARK: - Properties
    
    var viewModel: ChatListViewModel!
    
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


