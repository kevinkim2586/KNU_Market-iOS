import Foundation

protocol HomeViewModelDelegate: AnyObject {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
    
    func didFetchItemList()
    func failedFetchingItemList(with error: NetworkError)
}

class HomeViewModel {
    
    weak var delegate: HomeViewModelDelegate?
    
    var itemList: [ItemListModel] = [ItemListModel]()
    
    var isFetchingData: Bool = false
    
    var index: Int = 1
    
    //MARK: - 공구글 불러오기
    func fetchItemList() {
        
        /* Mock Data
        itemList.append(contentsOf: itemListMockData)
        self.delegate?.didFetchItemList()
        */
        
        isFetchingData = true

        ItemManager.shared.fetchItemList(at: self.index) { [weak self] result in
            
            guard let self = self else { return }

            switch result {
            case .success(let fetchedModel):

                if fetchedModel.isEmpty {
                    //self.isFetchingData = false
                    self.delegate?.didFetchItemList()
                    return
                }

                self.index += 1
                self.itemList.append(contentsOf: fetchedModel)
                self.isFetchingData = false
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
                
//                User.shared.id = model.id
//                User.shared.nickname = model.nickname
                self.delegate?.didFetchUserProfileInfo()
                
            case .failure(let error):
                self.delegate?.failedFetchingUserProfileInfo(with: error)
            }
        }
    }
    
    func resetValues() {
        
        itemList.removeAll()
        isFetchingData = false
        index = 1
    }
}

