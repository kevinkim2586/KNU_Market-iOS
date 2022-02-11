import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import ReusableKit

class MyPostsViewController: BaseViewController, View {
    
    typealias Reactor = MyPostsViewReactor

    //MARK: - Properties
    
    //MARK: - Constants
        
    //MARK: - UI
    
    let postTableView = UITableView().then {
        $0.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.cellId)
        $0.tableFooterView = UIView(frame: .zero)
    }
    
    let refreshControl = UIRefreshControl()
    
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
        postTableView.refreshControl = refreshControl
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
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // Output
        
        reactor.state
            .map { $0.postList }
            .bind(to: postTableView.rx.items(
                cellIdentifier: PostTableViewCell.cellId,
                cellType: PostTableViewCell.self)
            ) { indexPath, postList, cell in
                cell.configure(with: postList)
            }
            .disposed(by: disposeBag)
        
        postTableView.rx.itemSelected
            .map { Reactor.Action.seePostDetail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        postTableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.postTableView.frame.height > 0 else { return false }
                return offset.y + self.postTableView.frame.height >= self.postTableView.contentSize.height - 100
            }
            .filter { _ in reactor.currentState.isFetchingData == false }
            .filter { _ in reactor.currentState.needsToFetchMoreData == true }
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
            .map { $0.isFetchingData }
            .distinctUntilChanged()
            .filter { $0 == false }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.refreshControl.endRefreshing()
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
                } else {
                    self.postTableView.restoreEmptyView()
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - UITableViewDelegate

extension MyPostsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}

