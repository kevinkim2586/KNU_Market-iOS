import UIKit
import SnapKit
import ImageSlideshow
import RxSwift
import RxCocoa
import ReactorKit


class PostViewController: BaseViewController, View {
    
    typealias Reactor = PostViewReactor
    
#warning("edit 기능도 추가")
    //MARK: - Properties
    
    var viewModel: PostViewModel!
    var isFromChatVC: Bool = false
    
    
    // KMPostButtonView Menu Item
    @available(iOS 14.0, *)
    var menuItems: [UIAction] {
        guard let reactor = reactor else { return [] }
        // 사용자가 본인이 올린 글일 경우
        if reactor.currentState.postIsUserUploaded {
            return [
                UIAction(title: "수정하기", image: nil, handler: { [weak self] _ in
                    self?.reactor?.action.onNext(.editPost)
                }),
                UIAction(title: "삭제하기", image: nil, handler: { [weak self] _ in
                    self?.presentAlertWithConfirmation(title: "정말 삭제하시겠습니까?", message: nil)
                        .subscribe(onNext: { actionType in
                            switch actionType {
                            case .ok:
                                self?.reactor?.action.onNext(.deletePost)
                            case .cancel:
                                break
                            }
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag.init())
                })
            ]
        } else {
            return [
                UIAction(title: "신고하기", image: nil, handler: { [weak self] _ in
                    guard let nickname = reactor.currentState.postModel?.nickname else { return }
                    self?.presentReportUserVC(userToReport: nickname, postUID: reactor.currentState.pageId)
                }),
                UIAction(title: "이 사용자의 글 보지 않기", image: nil, handler: { [weak self] _ in
                    self?.reactor?.action.onNext(.blockUser)
                }),
            ]
        }
    }
    
    @available(iOS 14.0, *)
    var menu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    //MARK: - Constants
    
    private lazy var headerViewHeight = view.frame.size.height * 0.5

    //MARK: - UI
    
    let postControlButtonView = KMPostButtonView()

    lazy var postHeaderView: PostHeaderView = {
        let headerView = PostHeaderView(
            frame: CGRect(
                x: 0,
                y: 0, width: view.frame.size.width,
                height: headerViewHeight
            ),
            currentVC: self
        )
       return headerView
    }()

    let postBottomView = KMPostBottomView()
    
    lazy var postTableView = UITableView().then {
        $0.separatorColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.allowsSelection = true
        $0.register(PostCell.self, forCellReuseIdentifier: PostCell.cellId)
    }
    
    let refreshControl = UIRefreshControl().then {
        $0.tintColor = .clear
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
    
        view.addSubview(postTableView)
        view.addSubview(postControlButtonView)
        view.addSubview(postBottomView)
        configureHeaderView()
        postTableView.refreshControl = refreshControl
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
        postBottomView.snp.makeConstraints {
            $0.height.equalTo(80)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        postTableView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(postBottomView.snp.top).offset(0)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: PostViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refreshPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 뒤로가기
        postControlButtonView.backButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 메뉴 버튼
        postControlButtonView.menuButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                guard #available(iOS 14.0, *) else {
                    self.didPressMenuButton()
                    return
                }
            })
            .disposed(by: disposeBag)
        
        

        
        #warning("이 부분 추후에 리팩토링")
        linkOnClicked.asObservable()
            .withUnretained(self)
            .subscribe(onNext: { (_, url) in
                self.presentSafariView(with: url)
            })
            .disposed(by: disposeBag)
        
        
        postBottomView.enterChatButton.rx.tap
            .map { Reactor.Action.joinChat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        // Output
        
        reactor.state
            .map { $0.postModel }
            .filter { $0 != nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                
                if #available(iOS 14.0, *) {
                    self.postControlButtonView.menuButton.menu = self.menu
                    self.postControlButtonView.menuButton.showsMenuAsPrimaryAction = true
                }
                
    
                self.updatePostControlButtonView()
                self.updatePostHeaderView()
                self.updatePostBottomView()
                self.postTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isFetchingData }
            .distinctUntilChanged()
            .filter { $0 == false }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.alertMessage, $0.alertMessageType) }
            .distinctUntilChanged { $0.0 }
            .filter { $0.0 != nil }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_, alertInfo) in
                
                switch alertInfo.1 {
                case .appleDefault:
                    self.presentSimpleAlert(title: alertInfo.0!, message: "")
                    
                case .custom:
                    self.presentCustomAlert(title: "채팅방 참여 불가", message: alertInfo.0!)
                    
                case .simpleBottom:
                    self.showSimpleBottomAlert(with: alertInfo.0!)
           
                case .none: break
                }
            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.didFailFetchingPost }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.postTableView.refreshControl?.endRefreshing()
                self.postTableView.isHidden = true
                self.postBottomView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.didDeletePost }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: {  _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.didEnterChat }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let vc = ChatViewController()
                vc.roomUID = reactor.currentState.pageId
                vc.chatRoomTitle = reactor.currentState.title
                vc.isFirstEntrance = reactor.currentState.isFirstEntranceToChat
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isAttemptingToEnterChat }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (_, isAttempting) in
                self.postBottomView.enterChatButton.loadingIndicator(isAttempting)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.didUpdatePostGatheringStatus }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.reactor?.action.onNext(.refreshPage)
            })
            .disposed(by: disposeBag)
        
        // Notification Center
        
        NotificationCenterService.presentVerificationNeededAlert.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.presentUserVerificationNeededAlert()
            }
            .disposed(by: disposeBag)
        
        NotificationCenterService.didUpdatePost.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.reactor?.action.onNext(.refreshPage)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - UI Update Methods

extension PostViewController {
    
    private func configureHeaderView() {
        postTableView.tableHeaderView = nil
        postTableView.addSubview(postHeaderView)
        postTableView.contentInset = UIEdgeInsets(
            top: headerViewHeight,
            left: 0,
            bottom: 0,
            right: 0
        )
        postTableView.contentOffset = CGPoint(x: 0, y: -headerViewHeight)
        updateHeaderViewStyle()
    }
    
    func updateHeaderViewStyle() {
        var headerRect = CGRect(
            x: 0,
            y: -headerViewHeight,
            width: postTableView.bounds.width,
            height: headerViewHeight
        )
        if postTableView.contentOffset.y < -headerViewHeight {
            headerRect.origin.y = postTableView.contentOffset.y
            headerRect.size.height = -postTableView.contentOffset.y
        }
        postHeaderView.frame = headerRect
    }
    
    private func updatePostControlButtonView() {
        guard let reactor = reactor else { return }
        postControlButtonView.configure(
            isPostUserUploaded: reactor.currentState.postIsUserUploaded,
            isCompletelyDone: reactor.currentState.isCompletelyDone
        )
    }
    
    private func updatePostHeaderView() {
        guard let reactor = reactor else { return }
        postHeaderView.configure(
            imageSources: reactor.currentState.inputSources,
            postTitle: reactor.currentState.title,
            profileImageUid: reactor.currentState.postModel?.profileImageUID ?? "",
            userNickname: reactor.currentState.postModel?.nickname ?? "",
            locationName: reactor.currentState.location,
            dateString: reactor.currentState.date,
            viewCount: reactor.currentState.viewCount
        )
        updateHeaderViewStyle()

    }
    
    private func updatePostBottomView() {
        guard let reactor = reactor else { return }
        postBottomView.updateData(
            isPostCompletelyDone: reactor.currentState.isCompletelyDone,
            currentCount: reactor.currentState.currentlyGatheredPeople,
            totalCount: reactor.currentState.totalGatheringPeople,
            enableChatEnterButton: reactor.currentState.shouldEnableChatEntrance
        )
    }
}

//MARK: - Target Methods

extension PostViewController {
    
    
    func presentActionSheet(with actions: [UIAlertAction], title: String?) {
        let actionSheet = UIHelper.createActionSheet(with: actions, title: title)
        present(actionSheet, animated: true)
    }
}


