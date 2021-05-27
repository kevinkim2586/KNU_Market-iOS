import Foundation

protocol HomeViewModelDelegate {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
}

class HomeViewModel {
    
    var delegate: HomeViewModelDelegate?
    
    
    
    
    
    func loadUserProfile() {
        
        UserManager.shared.loadUserProfile { result in
            
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
}

