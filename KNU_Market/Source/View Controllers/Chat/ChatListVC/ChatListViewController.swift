import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then
import ReactorKit

class ChatListViewController: BaseViewController, View {
    
    //MARK: - Properties
    
    typealias Reactor = ChatListViewReactor
    
    //MARK: - UI
    
    let chatListTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.separatorColor = .clear
        $0.register(
            ChatListTableViewCell.self,
            forCellReuseIdentifier: ChatListTableViewCell.cellId
        )
    }
    
    let refreshControl = UIRefreshControl().then {
        $0.tintColor = .clear
    }
    
    let chatBarButtonItem = UIBarButtonItem().then {
        $0.title = "채팅"
        $0.style = .done
        $0.tintColor = .black
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        navigationItem.leftBarButtonItem = chatBarButtonItem
        view.addSubview(chatListTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        chatListTableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        setNavigationBarAppearance(to: .white)
    }
    
    private func configure() {
        chatListTableView.refreshControl = refreshControl
    }
    
    //MARK: - Binding
    
    func bind(reactor: ChatListViewReactor) {
        
        // Input
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.getChatList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        chatListTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.getChatList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        chatBarButtonItem.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                if reactor.currentState.roomList.count != 0 {
                    let topRow = IndexPath(row: 0, section: 0)
                    self.chatListTableView.scrollToRow(at: topRow, at: .top, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.roomList }
            .bind(to: chatListTableView.rx.items(
                cellIdentifier: ChatListTableViewCell.cellId,
                cellType: ChatListTableViewCell.self)
            ) { indexPath, chatList, cell in
                cell.configure(with: chatList)
                self.chatListTableView.restoreEmptyView()
            }
            .disposed(by: disposeBag)
        
        chatListTableView.rx.itemSelected
            .map { Reactor.Action.removeChatNotification($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        chatListTableView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (_, indexPath) in
                
                self.chatListTableView.deselectRow(at: indexPath, animated: true)
                
                let chatVC = ChatViewController()
                chatVC.hidesBottomBarWhenPushed = true
                chatVC.roomUID = reactor.currentState.roomList[indexPath.row].uuid
                chatVC.chatRoomTitle = reactor.currentState.roomList[indexPath.row].title
                chatVC.postUploaderUID = reactor.currentState.roomList[indexPath.row].userUID
                self.navigationController?.pushViewController(chatVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isFetchingData }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.needsToShowEmptyView }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (_, needsToShowEmptyView) in

                if needsToShowEmptyView {
                    self.chatListTableView.showEmptyView(
                        imageName: K.Images.emptyChatList,
                        text: "아직 활성화된 채팅방이 없네요!\n새로운 공구에 참여해보세요 :)"
                    )
                } else {
                    self.chatListTableView.restoreEmptyView()
                }
            })
            .disposed(by: disposeBag)
        
        
        // Notification Center
        
        NotificationCenterService.configureChatTabBadgeCount.addObserver()
            .bind { _ in
                self.configureChatTabBadgeCount()
            }
            .disposed(by: disposeBag)
        
        NotificationCenterService.updateChatList.addObserver()
            .map { _ in Reactor.Action.getChatList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

    }
}

