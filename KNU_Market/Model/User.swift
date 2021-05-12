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
    
    var profileImage: UIImage?
    
    
    
}
