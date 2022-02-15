import Foundation

class UserRegisterValues {
    
    static var shared: UserRegisterValues = UserRegisterValues()
    
    private init() {}
    
    var username: String = ""
    var password: String = ""
    var displayName: String = ""
    var emailForPasswordLoss: String = ""

    var email: String = ""
    var fcmToken: String = ""
}
