import UIKit

class User {

    //MARK: - Singleton
    static var shared: User = User()
    
    private init() {}
    
    var id: String = ""
    
    var nickname: String = ""
    
    var password: String = ""
    
    var email: String = ""
    
    var accessToken: String = ""
    
    var refreshToken: String = ""
    
    
    //MARK: - Profile Image
    var profileImage: UIImage? {
        
        didSet {
            guard let imageData = profileImage?.jpegData(compressionQuality: 1.0) else { return }
            self.profileImageData = imageData
        }
    }
    var profileImageData: Data?
    var profileImageCode: String = ""
    
    
    
}
