import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import ReusableKit

class MyPostsViewController: BaseViewController, View {
    
    typealias Reactor = MyPostsViewReactor

    //MARK: - Properties
    
    private var viewModel: PostListViewModel!
    
    //MARK: - Constants
    
    struct Reusable {
        static let postCell = ReusableCell<PostTableViewCell>()
    }
    
    //MARK: - UI
    
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
//        tableView.delegate = self
//        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
        return tableView
    }()
    
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
        title = "내가 올린 공구"
        createObserversForPresentingVerificationAlert()

//        setupViewModel()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        view.addSubview(postTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: MyPostsViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.fetchMyPosts }
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        
        postTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        // Output
        
        reactor.state
            .map { $0.postList }
            .bind(to: postTableView.rx.items(
                cellIdentifier: PostTableViewCell.cellId,
                cellType: PostTableViewCell.self)
            ) { indexPath, postList, cell in
                
                print("✅ postList: \(postList)")
                cell.configure(with: postList)
            }
            .disposed(by: disposeBag)
        
        postTableView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { (_, indexPath) in
                self.postTableView.deselectRow(at: indexPath, animated: true)
                
                
                
            })
            .disposed(by: disposeBag)
        
        postTableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.postTableView.frame.height > 0 else { return false }
                return offset.y + self.postTableView.frame.height >= self.postTableView.contentSize.height - 100
            }
            .map { _ in Reactor.Action.fetchMyPosts }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isFetchingData }
            .subscribe(onNext: { isFetchingData in
                
                self.postTableView.tableFooterView = isFetchingData
                ? UIHelper.createSpinnerFooterView(in: self.view)
                : nil
            })
            .disposed(by: disposeBag)

        
        reactor.state
            .map { $0.needsToShowEmptyView }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (_, needsToShowEmptyView) in
                
                if needsToShowEmptyView {
                    self.postTableView.showEmptyView(
                        imageName: K.Images.emptyChatList,
                        text: "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
                    )
                }
            })
            .disposed(by: disposeBag)
        

        

        
   
        
    }
}

//MARK: - HomeViewModelDelegate

//extension MyPostsViewController: PostListViewModelDelegate {
    
//    func didFetchPostList() {
//        postTableView.reloadData()
//        postTableView.refreshControl?.endRefreshing()
//        postTableView.tableFooterView = nil
//        postTableView.restoreEmptyView()
//        if viewModel.postList.count == 0 {
//            postTableView.showEmptyView(
//                imageName: K.Images.emptyChatList,
//                text: "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
//            )
//        }
//    }
//
//    func failedFetchingPostList(errorMessage: String, error: NetworkError) {
//        if viewModel.postList.count == 0 {
//            postTableView.showEmptyView(
//                imageName: K.Images.emptyChatList,
//                text: errorMessage
//            )
//        }
//        postTableView.refreshControl?.endRefreshing()
//        postTableView.reloadData()
//        postTableView.tableFooterView = nil
//    }
//}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPostsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel?.postList.count ?? 0
//    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cellIdentifier = PostTableViewCell.cellId
//
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: cellIdentifier,
//            for: indexPath
//        ) as? PostTableViewCell else {
//            return UITableViewCell()
//        }
//        cell.configure(with: viewModel.postList[indexPath.row])
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let postVC = PostViewController(
            viewModel: PostViewModel(
                pageId: viewModel.postList[indexPath.row].uuid,
                postManager: PostManager(),
                chatManager: ChatManager()
            ),
            isFromChatVC: false
        )
        
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc private func refreshTableView() {
        UIView.animate(
            views: self.postTableView.visibleCells,
            animations: Animations.forTableViews,
            reversed: true,
            initialAlpha: 1.0,   // 보이다가
            finalAlpha: 0.0,     // 안 보이게
            completion: {
                self.viewModel.resetValues()
                self.viewModel.fetchPostList(fetchCurrentUsers: true)
            }
        )
    }
}

////MARK: - UIScrollViewDelegate
//
//extension MyPostsViewController: UIScrollViewDelegate {
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let position = scrollView.contentOffset.y
//        if position > (postTableView.contentSize.height - 80 - scrollView.frame.size.height) {
//            if !viewModel.isFetchingData {
//                postTableView.tableFooterView = UIHelper.createSpinnerFooterView(in: self.view)
//                viewModel.fetchPostList(fetchCurrentUsers: true)
//            }
//        }
//    }
//}
//
//
