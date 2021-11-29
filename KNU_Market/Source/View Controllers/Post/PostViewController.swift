import UIKit
import SnapKit
import ImageSlideshow
import SafariServices


class PostViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var viewModel: PostViewModel!
    private var isFromChatVC: Bool = false
    
    //MARK: - Constants
    
    private lazy var headerViewHeight = view.frame.size.height * 0.5

    //MARK: - UI
    lazy var postControlButtonView: KMPostButtonView = {
        let view = KMPostButtonView()
        view.delegate = self
        return view
    }()
        
    lazy var postHeaderView: PostHeaderView = {
        let headerView = PostHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerViewHeight),
            currentVC: self
        )
       return headerView
    }()

    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .clear
        tableView.refreshControl?.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        return tableView
    }()
    
    lazy var postBottomView: KMPostBottomView = {
        let view = KMPostBottomView()
        view.delegate = self
        return view
    }()
    
    
    //MARK: - Initialization
    
    init(viewModel: PostViewModel, isFromChatVC: Bool = false) {
        super.init()
        self.viewModel = viewModel
        self.viewModel.delegate = self
        self.isFromChatVC = isFromChatVC
        hidesBottomBarWhenPushed = true
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
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
 
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(postTableView)
        view.addSubview(postControlButtonView)
        view.addSubview(postBottomView)
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
    
    private func configure() {
        loadInitialMethods()
        createObservers()
        configureHeaderView()
    }
    
    private func loadInitialMethods() {
        viewModel.fetchPostDetails()
        viewModel.fetchEnteredRoomInfo()
    }

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
    
    func createObservers() {
        
        createObserversForPresentingVerificationAlert()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPage),
            name: .didUpdatePost,
            object: nil
        )
    }

}

//MARK: - Target Methods

extension PostViewController {
    

    @objc func refreshPage() {
        postTableView.refreshControl?.endRefreshing()
        viewModel.fetchPostDetails()
    }
    
    private func presentActionSheet(with actions: [UIAlertAction], title: String?) {
        let actionSheet = UIHelper.createActionSheet(with: actions, title: title)
        present(actionSheet, animated: true)
    }
}

//MARK: - KMPostButtonViewDelegate

extension PostViewController: KMPostButtonViewDelegate {
    
    func didPressBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func didPressGatheringStatusButton() {

        if let isCompletelyDone = viewModel.model?.isCompletelyDone {
            
            if isCompletelyDone {
                let cancelMarkDoneAction = UIAlertAction(
                    title: "다시 모집하기",
                    style: .default
                ) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.cancelMarkPostDone()
                }
                presentActionSheet(with: [cancelMarkDoneAction], title: "모집 상태 변경")
            } else {
                let doneAction = UIAlertAction(
                    title: "모집 완료하기",
                    style: .default
                ) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.markPostDone()
                }
                presentActionSheet(with: [doneAction], title: "모집 상태 변경")
            }
        }
    }
    
    func didPresseTrashButton() {
    
        let deleteAction = UIAlertAction(
            title: "공구 삭제하기",
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presentAlertWithCancelAction(
                title: "정말 삭제하시겠습니까?",
                message: ""
            ) { selectedOk in
                if selectedOk {
                    showProgressBar()
                    self.viewModel.deletePost()
                }
            }
        }
        presentActionSheet(with: [deleteAction], title: nil)
    }
    
    func didPressMenuButton() {

        if viewModel.postIsUserUploaded {
                        
            let editAction = UIAlertAction(
                title: "글 수정하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    
                    let vc = UploadPostViewController(
                        viewModel: UploadPostViewModel(
                            postManager: PostManager(),
                            mediaManager: MediaManager()
                        ),
                        editModel: self.viewModel.modelForEdit
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            presentActionSheet(with: [editAction], title: nil)
        } else {
            
            let reportAction = UIAlertAction(
                title: "게시글 신고하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                guard let nickname = self.viewModel.model?.nickname else { return }
                self.presentReportUserVC(
                    userToReport: nickname,
                    postUID: self.viewModel.pageID
                )
            }
            let blockAction = UIAlertAction(
                title: "이 사용자의 글 보지 않기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.askToBlockUser()
            }
            presentActionSheet(with: [reportAction, blockAction], title: nil)

        }
    }
    
    
    func askToBlockUser() {
        
        guard let reportNickname = viewModel.model?.nickname,
              let reportUID = viewModel.model?.userUID else {
            showSimpleBottomAlert(with: "현재 해당 기능을 사용할 수 없습니다.😥")
            return
        }
    
        guard !User.shared.bannedPostUploaders.contains(reportUID) else {
            showSimpleBottomAlert(with: "이미 \(reportNickname)의 글을 안 보기 처리하였습니다.🧐")
            return
        }
        
        presentAlertWithCancelAction(
            title: "\(reportNickname)님의 글 보지 않기",
            message: "홈화면에서 위 사용자의 게시글이 더는 보이지 않도록 설정하시겠습니까? 한 번 설정하면 해제할 수 없습니다."
        ) { selectedOk in
            if selectedOk { self.viewModel.blockUser(userUID: reportUID) }
        }
    }
}

//MARK: - KMPostBottomViewDelegate

extension PostViewController: KMPostBottomViewDelegate {
    
    func didPressEnterChatButton() {
        
        postBottomView.enterChatButton.loadingIndicator(true)
        
        if isFromChatVC { navigationController?.popViewController(animated: true) }
        viewModel.joinPost()
    }
}

//MARK: - PostViewModelDelegate

extension PostViewController: PostViewModelDelegate {
    
    func didFetchPostDetails() {
        DispatchQueue.main.async {
            self.postTableView.refreshControl?.endRefreshing()
            self.updatePostInformation()
        }
    }
    
    func failedFetchingPostDetails(with error: NetworkError) {
        self.postTableView.refreshControl?.endRefreshing()
        
        postTableView.isHidden = true
        postBottomView.isHidden = true
        
        showSimpleBottomAlertWithAction(
            message: "존재하지 않는 글입니다 🧐",
            buttonTitle: "홈으로",
            action: {
                self.navigationController?.popViewController(animated: true)
            }
        )
    }
    
    func didDeletePost() {
        dismissProgressBar()
        showSimpleBottomAlert(with: "게시글 삭제 완료 🎉")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .updatePostList, object: nil)
        }
    }
    
    func failedDeletingPost(with error: NetworkError) {
        dismissProgressBar()
        showSimpleBottomAlertWithAction(
            message: error.errorDescription,
            buttonTitle: "재시도"
        ) {
            self.viewModel.deletePost()
        }
    }
    
    func didMarkPostDone() {
        showSimpleBottomAlert(with: "모집 완료를 축하합니다.🎉")
        refreshPage()
    }
    
    func failedMarkingPostDone(with error: NetworkError) {
        dismissProgressBar()
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didCancelMarkPostDone() {
        refreshPage()
    }
    
    func failedCancelMarkPostDone(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didEnterChat(isFirstEntrance: Bool) {
        
        let vc = ChatViewController()
        
        vc.roomUID = viewModel.pageID
        vc.chatRoomTitle = viewModel.model?.title ?? ""
        
        vc.isFirstEntrance = isFirstEntrance ? true : false
        
        navigationController?.pushViewController(vc, animated: true)
        postBottomView.enterChatButton.loadingIndicator(false)
    }
    
    func failedJoiningChat(with error: NetworkError) {
        presentKMAlertOnMainThread(
            title: "채팅방 참여 불가",
            message: error.errorDescription,
            buttonTitle: "확인"
        )
        postBottomView.enterChatButton.loadingIndicator(false)
    }
    
    func didBlockUser() {
        showSimpleBottomAlert(with: "앞으로 \(viewModel.model?.nickname ?? "해당 유저")의 게시글이 목록에서 보이지 않습니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func didDetectURL(with string: NSMutableAttributedString) {
        postTableView.reloadData()
    }
    
    func failedLoadingData(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
}

//MARK: - Data Configuration

extension PostViewController {
    
    func updatePostInformation() {
        updatePostControlButtonView()
        updatePostHeaderView()
        updatePostBottomView()
        postTableView.reloadData()
    }
    
    private func updatePostControlButtonView() {
        
        postControlButtonView.configure(
            isPostUserUploaded: viewModel.postIsUserUploaded,
            isCompletelyDone: viewModel.isCompletelyDone
        )
    }
    
    private func updatePostHeaderView() {
        
        postHeaderView.configure(
            imageSources: viewModel.imageSources,
            postTitle: viewModel.model?.title ?? "로딩 중..",
            profileImageUid: viewModel.model?.profileImageUID ?? "",
            userNickname: viewModel.model?.nickname ?? "-",
            locationName: viewModel.location,
            dateString: viewModel.date,
            viewCount: viewModel.viewCount
        )
        updateHeaderViewStyle()
    }
    
    private func updatePostBottomView() {
        
        postBottomView.updateData(
            isPostCompletelyDone: viewModel.isCompletelyDone,
            currentCount: viewModel.currentlyGatheredPeople,
            totalCount: viewModel.totalGatheringPeople,
            enableChatEnterButton: viewModel.shouldEnableChatEntrance
        )
    }
    
    
    

    
}



//MARK: - UITableViewDelegate, UITableViewDataSource

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "PostCell")
        cell.selectionStyle = .none
        
        let postDetail = viewModel.model?.postDetail ?? "로딩 중.."
    
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : labelStyle]
        
        cell.textLabel?.numberOfLines = 0
        
        if let postDetailWithUrl = viewModel.postDetailWithUrl {
            cell.textLabel?.attributedText = postDetailWithUrl
        } else {
            cell.textLabel?.attributedText = NSAttributedString(
                string: postDetail,
                attributes: attributes
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel.userIncludedURL else { return }
        presentSafariView(with: url)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderViewStyle()
    }
}
