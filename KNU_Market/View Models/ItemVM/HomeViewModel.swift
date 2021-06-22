import Foundation

protocol HomeViewModelDelegate {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
    
    func didFetchItemList()
    func failedFetchingItemList(with error: NetworkError)
}

class HomeViewModel {
    
    var delegate: HomeViewModelDelegate?
    
    var itemList: [ItemListModel] = [ItemListModel]()
    
    var needsToFetchMoreData: Bool = true
    
    var isPaginating: Bool = false
    
    var index: Int = 1
    
    //MARK: - 공구글 불러오기
    func fetchItemList(pagination: Bool = false) {
        
        if pagination {
            isPaginating = true
        }
        
        ItemManager.shared.fetchItemList(at: self.index) { [weak self] result in
            
            guard let self = self else { return }
            
            self.index += 1
            
            switch result {
            case .success(let fetchedModel):
                
                if fetchedModel.isEmpty {
                    self.needsToFetchMoreData = false
                    self.delegate?.didFetchItemList()
                    return
                }
                
                self.itemList.append(contentsOf: fetchedModel)
                
                //self.itemList = fetchedModel
                
                if pagination {
                    self.isPaginating = false
                }
                
                self.delegate?.didFetchItemList()
                
            case .failure(let error):
                self.delegate?.failedFetchingItemList(with: error)
            }
        }
    }

    //MARK: - 유저 정보 불러오기
    func loadUserProfile() {
        
        UserManager.shared.loadUserProfile { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                
                print("HomeViewModel - fetched user info: \(model.id), \(model.nickname), \(model.profileImageCode)")
                
                User.shared.id = model.id
                User.shared.nickname = model.nickname
                self.delegate?.didFetchUserProfileInfo()
                
            case .failure(let error):
                self.delegate?.failedFetchingUserProfileInfo(with: error)
            }
        }
    }
    
    func resetValues() {
        
        itemList.removeAll()
        needsToFetchMoreData = true
        isPaginating = false
        index = 1
    }
}

