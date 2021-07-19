import UIKit

class SearchPostViewController: UIViewController {

    //@IBOutlet var tableView: UITableView!
    
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
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
        
        guard let searchKeyword = searchBar.text else { return }
        
        
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchPostViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }


}


//MARK: - Initialization & UI Configuration

extension SearchPostViewController {
    
    func initialize() {
        
        initializeSearchBar()
        //initializeTableView()
        
    }
    
//    func initializeTableView() {
//
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        let nibName = UINib(nibName: Constants.XIB.itemTableViewCell, bundle: nil)
//        tableView.register(nibName, forCellReuseIdentifier: Constants.cellID.itemTableViewCell)
//
//    }
    
    func initializeSearchBar() {
        
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        
        self.navigationItem.searchController = searchController

//        let cancel = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
//                                     style: .plain,
//                                     target: self,
//                                     action: #selector(goBackToHome))
//        self.navigationItem.leftBarButtonItem = cancel
//
//        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - cancel.width - 70, height: 0))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchBar)
//
//
//
//        searchBar.delegate = self
//        searchBar.placeholder = "검색어 입력"
    }
    
    @objc func goBackToHome() {
        navigationController?.popViewController(animated: true)
    }
}
