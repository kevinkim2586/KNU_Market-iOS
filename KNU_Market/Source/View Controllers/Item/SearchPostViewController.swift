import UIKit
import HGPlaceholders

class SearchPostViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var viewModel = SearchPostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

//MARK: - SearchPostViewModelDelegate

extension SearchPostViewController: SearchPostViewModelDelegate {
    
    func didFetchSearchList() {
        
        if viewModel.itemList.count == 0 {
            tableView.showEmptyView(
                imageName: K.Images.emptySearchPlaceholder,
                text: K.placeHolderTitle.emptySearchTitleList.randomElement()!
            )
        }
        tableView.reloadData()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingSearchList(with error: NetworkError) {
        
        tableView.reloadData()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
        
        let errorText = error == .E401 ? "두 글자 이상 입력해주세요." : "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        
        tableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: errorText
        )

    }
}

//MARK: - UISearchBarDelegate

extension SearchPostViewController: UISearchBarDelegate {
    
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
            tableView.showEmptyView(
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

//MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchPostViewController: UITableViewDelegate, UITableViewDataSource {

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
        
        guard let itemVC = storyboard?.instantiateViewController(
            identifier: K.StoryboardID.itemVC
        ) as? ItemViewController else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[indexPath.row].uuid
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}

//MARK: - UIScrollViewDelegate

extension SearchPostViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 20 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                viewModel.fetchSearchResults()
            }
        }
    }
}

//MARK: - Placeholder Delegate

extension SearchPostViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        self.viewModel.resetValues()
        self.viewModel.fetchSearchResults()
    }
}

//MARK: - Initialization & UI Configuration

extension SearchPostViewController {
    
    func initialize() {
        title = "공구 글 검색"
        
        tableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: K.placeHolderTitle.prepareSearchTitleList.randomElement()!
        )
        
        viewModel.delegate = self
        
        initializeSearchBar()
        initializeTableView()
    }
    
    func initializeSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "검색어 입력"
    }
    
    func initializeTableView() {
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
    }
    
}
