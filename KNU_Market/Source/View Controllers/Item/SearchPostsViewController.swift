import UIKit
import HGPlaceholders
import SnapKit

class SearchPostsViewController: BaseViewController {

    //MARK: - Properties
    
    private var viewModel: SearchPostViewModel!
    
    //MARK: - Constants
    
    //MARK: - UI
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "검색어 입력"
        return searchBar
    }()
    
    lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
        return tableView
    }()
    
    //MARK: - Initialization
    
    init(viewModel: SearchPostViewModel) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.viewModel = viewModel
        viewModel.delegate = self
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
        
        view.addSubview(searchBar)
        view.addSubview(searchTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(10)
        }
        
        searchTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    private func configure() {
        title = "공구 글 검색"
        searchTableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: K.placeHolderTitle.prepareSearchTitleList.randomElement()!
        )
    }
}

//MARK: - SearchPostViewModelDelegate

extension SearchPostsViewController: SearchPostViewModelDelegate {
    
    func didFetchSearchList() {
        
        if viewModel.itemList.count == 0 {
            searchTableView.showEmptyView(
                imageName: K.Images.emptySearchPlaceholder,
                text: K.placeHolderTitle.emptySearchTitleList.randomElement()!
            )
        }
        searchTableView.reloadData()
        searchTableView.tableFooterView = nil
        searchTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingSearchList(with error: NetworkError) {
        
        searchTableView.reloadData()
        searchTableView.tableFooterView = nil
        searchTableView.tableFooterView = UIView(frame: .zero)
        
        let errorText = error == .E401
        ? "두 글자 이상 입력해주세요."
        : "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        
        searchTableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: errorText
        )

    }
}

//MARK: - UISearchBarDelegate

extension SearchPostsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchKey = searchBar.text else { return }
        guard !searchKey.hasEmojis else {
            searchBar.resignFirstResponder()
            searchTableView.showEmptyView(
                imageName: K.Images.emptySearchPlaceholder,
                text: "이모티콘 검색은 지원하지 않습니다!"
            )
            return
        }
        searchBar.resignFirstResponder()
        viewModel.resetValues()
        viewModel.searchKeyword = searchKey
        viewModel.fetchSearchResults()
        
    }
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension SearchPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.itemList.count { return UITableViewCell() }
        
        let cellIdentifier = PostTableViewCell.cellId
        
        tableView.restoreEmptyView()
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? PostTableViewCell else { return UITableViewCell() }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let postVC = PostViewController(
            viewModel: PostViewModel(
                pageId: viewModel.itemList[indexPath.row].uuid,
                postManager: PostManager(),
                chatManager: ChatManager()
            ),
            isFromChatVC: false
        )
        
        navigationController?.pushViewController(postVC, animated: true)
    }
}

//MARK: - UIScrollViewDelegate

extension SearchPostsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (searchTableView.contentSize.height - 20 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                viewModel.fetchSearchResults()
            }
        }
    }
}

//MARK: - Placeholder Delegate

extension SearchPostsViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        self.viewModel.resetValues()
        self.viewModel.fetchSearchResults()
    }
}
