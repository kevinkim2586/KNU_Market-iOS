import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
    
    func didFetchUserProfileImage()
    
    func didFetchItemList()
    func failedFetchingItemList(with error: NetworkError)
}

class HomeViewModel {
    
    weak var delegate: HomeViewModelDelegate?
    
    var itemList: [ItemListModel] = [ItemListModel]()
    
    var isFetchingData: Bool = false
    
    var index: Int = 1
    
    
    //MARK: - 공구글 불러오기
    func fetchItemList(fetchCurrentUsers: Bool = false) {
        
        /* Mock Data
        itemList.append(contentsOf: itemListMockData)
        self.delegate?.didFetchItemList()
        */
        
        isFetchingData = true

        ItemManager.shared.fetchItemList(at: self.index, fetchCurrentUsers: fetchCurrentUsers) { [weak self] result in
            
            guard let self = self else { return }

            switch result {
            case .success(let fetchedModel):

                if fetchedModel.isEmpty {
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

    //MARK: - 사용자 프로필 정보 불러오기
    //TODO: - 아래 함수는 MyPageViewModel 이랑 중복되는데 이걸 Observer Pattern 으로 변경하기
    func loadUserProfile() {
        
        UserManager.shared.loadUserProfile { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                
                self.fetchProfileImage(with: model.profileImageCode)
                self.delegate?.didFetchUserProfileInfo()
                
            case .failure(let error):
                self.delegate?.failedFetchingUserProfileInfo(with: error)
            }
        }
    }
    
    
    func fetchProfileImage(with imageUID: String) {
        
        MediaManager.shared.requestMedia(from: imageUID) { result in
            
            switch result {
            case .success(let imageData):
                
                print("✏️ UserManager - fetchProfileImage SUCCESS")
                
                if let imageData = imageData {
                    User.shared.profileImage = UIImage(data: imageData) ?? nil
                } else {
                    User.shared.profileImage = nil
                }
                
                self.delegate?.didFetchUserProfileImage()
            
            case .failure(_):
                print("❗️ UserManager - Failed to fetchProfileImage")
                User.shared.profileImage = nil
            }
        }
        
    }
    
    func resetValues() {
        
        itemList.removeAll()
        isFetchingData = false
        index = 1
    }
}

