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
        
        print("✏️ SearchPostVC - didFetchSearchList")
        tableView.reloadData()
        tableView.tableFooterView = nil
    }
    
    func failedFetchingSearchList(with error: NetworkError) {
        
        print("✏️ SearchPostVC - failedFetchingSearchList")
        //tableView.showErrorPlaceholder()
        tableView.tableFooterView = nil
        self.showSimpleBottomAlert(with: "일시적인 연결 문제가 있습니다. 🥲")
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
        
        print("✏️ searchKey: \(searchKey)")
        
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
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let itemVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.itemVC) as? ItemViewController else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[indexPath.row].uuid
        
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
}

//MARK: - UIScrollViewDelegate

extension SearchPostViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 80 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                tableView.tableFooterView = createSpinnerFooterView()
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
        
        viewModel.delegate = self
        
        initializeSearchBar()
        initializeTableView()
        
    }
    
    func initializeSearchBar() {

        searchBar.delegate = self
        searchBar.placeholder = "검색어 입력"
    }
    
    func initializeTableView() {

        //tableView.placeholderDelegate = self
        tableView.delegate = self
        tableView.dataSource = self

        let nibName = UINib(nibName: Constants.XIB.itemTableViewCell, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: Constants.cellID.itemTableViewCell)

    }
    

    
    
}
