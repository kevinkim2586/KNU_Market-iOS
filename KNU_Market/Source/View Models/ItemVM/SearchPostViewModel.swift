import Foundation

protocol SearchPostViewModelDelegate: AnyObject {
    func didFetchSearchList()
    func failedFetchingSearchList(with error: NetworkError)
}

class SearchPostViewModel {
    
    //MARK: - Properties
    
    private var itemManager: ItemManager
    
    weak var delegate: SearchPostViewModelDelegate?
    
    var itemList: [ItemListModel] = [ItemListModel]()

    var isFetchingData: Bool = false
    
    var index: Int = 1
    
    var searchKeyword: String?
    
    //MARK: - Initialization
    
    init(itemManager: ItemManager) {
        self.itemManager = itemManager
    }
    
    //MARK: - Methods
    
    func fetchSearchResults() {
        
        isFetchingData = true
        
        guard let keyword = self.searchKeyword else { return }
        
        itemManager.fetchSearchResults(
            at: index,
            keyword: keyword
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedModel):
                
                if fetchedModel.isEmpty {
                    self.delegate?.didFetchSearchList()
                    return
                }
                self.index += 1
                self.itemList.append(contentsOf: fetchedModel)
                self.isFetchingData = false
                self.delegate?.didFetchSearchList()
                
            case .failure(let error):
                self.delegate?.failedFetchingSearchList(with: error)
            }
        }
    }
    
    func resetValues() {
        
        itemList.removeAll()
        searchKeyword = nil
        isFetchingData = false
        index = 1
    }
    
    
}
