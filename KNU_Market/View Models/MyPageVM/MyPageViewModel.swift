import UIKit

protocol MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo()
    func didFetchProfileImage()
    func didUpdateUserProfileToServer()
    
    func failedLoadingUserProfileInfo(with error: NetworkError)
    func failedUpdatingUserProfileToServer(with error: NetworkError)
    func showToastMessage(with message: String)
    
}

class MyPageViewModel {
    
    var delegate: MyPageViewModelDelegate?
    
    var userNickname: String = ""
    
    var profileImage: UIImage = UIImage()
    

    
    func loadUserProfile() {
        
        UserManager.shared.loadUserProfile { result in
            
            switch result {
            case .success(let model):
                
                self.userNickname = model.nickname
                self.delegate?.didLoadUserProfileInfo()
                OperationQueue().addOperation {
                    self.fetchProfileImage(with: model.profileImage)
                }
            
            case .failure(let error):
                self.delegate?.failedLoadingUserProfileInfo(with: error)
            }
        }
    }
    
    func fetchProfileImage(with urlString: String) {
        
        UserManager.shared.requestMedia(from: urlString) { result in
            
            switch result {
            case .success(let imageData):
                
                if let imageData = imageData {
                    
                    self.profileImage = UIImage(data: imageData) ?? UIImage(named: "pick_profile_picture")!
                    self.delegate?.didFetchProfileImage()
                } else {
                    self.delegate?.showToastMessage(with: "프로필 사진 가져오기 실패")
                }

            case .failure(_):
                self.delegate?.showToastMessage(with: "프로필 사진 가져오기 실패")
            }
        }
    }
    
    
    func updateUserProfileToServer(with image: UIImage) {
        
        
        
    }
}
