import Foundation

class UserRegisterValues {
    
    static var shared: UserRegisterValues = UserRegisterValues()
    
    private init() {}
    
    var nickname: String = ""
    var password: String = ""
    var profileImage: Data?
    var email: String = ""
}
