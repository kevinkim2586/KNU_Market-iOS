import UIKit

let profileImageCache = NSCache<AnyObject, AnyObject>()

protocol MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo()
    func didFetchProfileImage()
    func didUpdateUserProfileImage()
    func didUploadImageToServerFirst(with uid: String)
    
    func failedLoadingUserProfileInfo(with error: NetworkError)
    func failedUploadingImageToServerFirst(with error: NetworkError)
    func failedUpdatingUserProfileImage(with error: NetworkError)
    
    func showToastMessage(with message: String)
}

class MyPageViewModel {
    
    var delegate: MyPageViewModelDelegate?
    
    var tableViewOptions: [String] = ["개발자에게 건의사항 보내기","설정","서비스 이용약관"]
    
    var userNickname: String = ""
    
    var profileImage: UIImage = UIImage() {
        didSet {
            profileImageCache.setObject(self.profileImage, forKey: "profileImageCache" as AnyObject)
            User.shared.profileImage = self.profileImage
        }
    }
    
    //MARK: - 사용자 프로필 정보 불러오기
    func loadUserProfile() {
     
        UserManager.shared.loadUserProfile { result in
            
            switch result {
            case .success(let model):
                
                print("MyPageViewModel - fetched user info: \(model.id), \(model.nickname), \(model.profileImageCode)")
                
                self.userNickname = model.nickname
                User.shared.nickname = model.nickname
                self.delegate?.didLoadUserProfileInfo()
                
                // 이미 받아온 프로필 이미지 Cache 가 있다면
                if let imageFromCache = profileImageCache.object(forKey: "profileImageCache" as AnyObject) as? UIImage {
                    self.profileImage = imageFromCache
                    self.delegate?.didFetchProfileImage()
                    return
                }
                
                OperationQueue().addOperation {
                    self.fetchProfileImage(with: model.profileImageCode)
                }
            
            case .failure(let error):
                self.delegate?.failedLoadingUserProfileInfo(with: error)
            }
        }
    }
    
    //MARK: - 사용자 프로필 이미지 불러오기
    func fetchProfileImage(with urlString: String) {
        
        UserManager.shared.requestMedia(from: urlString) { result in
            
            switch result {
            case .success(let imageData):
                
                print("MyPageViewModel - fetchProfileImage .success()")
                
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
    
    //MARK: - 프로필 이미지를 서버에 먼저 올리기 -> uid 값 반환 목적
    func uploadImageToServerFirst(with image: UIImage) {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            self.delegate?.failedUploadingImageToServerFirst(with: .E000)
            return
        }
        
        UserManager.shared.uploadImage(with: imageData) { result in
            
            switch result {
            
            case .success(let uid):
                User.shared.profileImageCode = uid
                self.delegate?.didUploadImageToServerFirst(with: uid)
                
            case .failure(let error):
                self.delegate?.failedUploadingImageToServerFirst(with: error)
            }

        }
    }
    
    //MARK: - 그 다음에 프로필 이미지 수정 (DB상)
    func updateUserProfileImage(with uid: String) {
        
        UserManager.shared.updateUserProfileImage(with: uid) { result in
            
            switch result {
            
            case .success(_):
                profileImageCache.removeAllObjects()
                self.delegate?.didUpdateUserProfileImage()
            case .failure(let error):
                self.delegate?.failedUpdatingUserProfileImage(with: error)
            }
        }
    }
    

}
