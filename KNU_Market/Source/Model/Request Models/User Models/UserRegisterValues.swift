import Foundation

class UserRegisterValues {
    
    static var shared: UserRegisterValues = UserRegisterValues()
    
    private init() {}
    
    var userId: String = ""
    var password: String = ""
    var nickname: String = ""
    var emailForPasswordLoss: String = ""

    var email: String = ""
    var fcmToken: String = ""
}
