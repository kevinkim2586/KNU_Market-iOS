import UIKit

let profileImageCache = NSCache<AnyObject, AnyObject>()


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
    
    var profileImage: UIImage = UIImage() {
        didSet {
            profileImageCache.setObject(self.profileImage, forKey: "profileImageCache" as AnyObject)
            User.shared.profileImage = self.profileImage
        }
    }
    
    func loadUserProfile() {
    
        UserManager.shared.loadUserProfile { result in
            
            switch result {
            case .success(let model):
                
                self.userNickname = model.nickname
                self.delegate?.didLoadUserProfileInfo()
                
                // 이미 받아온 프로필 이미지 Cache 가 있다면
                if let imageFromCache = profileImageCache.object(forKey: "profileImageCache" as AnyObject) as? UIImage {
                    self.profileImage = imageFromCache
                    return
                }
                
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
