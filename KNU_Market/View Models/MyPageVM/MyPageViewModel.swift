import UIKit


protocol MyPageViewModelDelegate: AnyObject {
    
    func didLoadUserProfileInfo()
    func didFetchProfileImage()
    func didUpdateUserProfileImage()
    func didUploadImageToServerFirst(with uid: String)
    
    func failedLoadingUserProfileInfo(with error: NetworkError)
    func failedUploadingImageToServerFirst(with error: NetworkError)
    func failedUpdatingUserProfileImage(with error: NetworkError)
    
    func showErrorMessage(with message: String)
}

class MyPageViewModel {
    
    weak var delegate: MyPageViewModelDelegate?
    
    var tableViewSection_1: [String] = ["내가 올린 글", "설정"]
    var tableViewSection_2: [String] = ["개발자에게 건의사항 보내기", "서비스 이용약관", "개인정보 처리방침", "개발자 정보"]

    var userNickname: String {
        return User.shared.nickname
    }
    
    var profileImage: UIImage? {
        didSet {
            if profileImage != nil {
                profileImageCache.setObject(self.profileImage!, forKey: "profileImageCache" as AnyObject)
                User.shared.profileImage = self.profileImage
            }
        }
    }
    
    //MARK: - 사용자 프로필 정보 불러오기
    func loadUserProfile() {
     
        UserManager.shared.loadUserProfile { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let model):
                self.delegate?.didLoadUserProfileInfo()
                
                // 이미 받아온 프로필 이미지 Cache 가 있다면
                if let imageFromCache = profileImageCache.object(forKey: "profileImageCache" as AnyObject) as? UIImage {
                    self.profileImage = imageFromCache
                    self.delegate?.didFetchProfileImage()
                    return
                }
                
                if model.profileImageCode == "default" { return }
                
                // 없다면 DB에서 받아오기
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
        
        MediaManager.shared.requestMedia(from: urlString) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let imageData):
                
                print("MyPageViewModel - fetchProfileImage .success()")
                
                if let imageData = imageData {
                    
                    self.profileImage = UIImage(data: imageData) ?? nil
                    self.delegate?.didFetchProfileImage()
                    
                // 그냥 이미지를 애초에 사용자가 안 올린 경우에
                } else {
                    
                    self.profileImage = nil
                    self.delegate?.didFetchProfileImage()
                }

            case .failure(_):
                self.delegate?.showErrorMessage(with: "프로필 사진 불러오기 실패 😅")
            }
        }
    }
    
    //MARK: - 프로필 이미지를 서버에 먼저 올리기 -> uid 값 반환 목적
    func uploadImageToServerFirst(with image: UIImage) {
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            self.delegate?.failedUploadingImageToServerFirst(with: .E000)
            return
        }
        
        MediaManager.shared.uploadImage(with: imageData) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let uid):
                User.shared.profileImageUID = uid
                print("uploadImage success with new uid: \(uid)")
                self.delegate?.didUploadImageToServerFirst(with: uid)
                
            case .failure(let error):
                self.delegate?.failedUploadingImageToServerFirst(with: error)
                print("uploadImage failed with error: \(error.errorDescription)")
            }
        }
    }
    
    //MARK: - 그 다음에 프로필 이미지 수정 (DB상)
    func updateUserProfileImage(with uid: String) {
        
        UserManager.shared.updateUserProfileImage(with: uid) { [weak self] result in
            
            guard let self = self else { return }
            
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
