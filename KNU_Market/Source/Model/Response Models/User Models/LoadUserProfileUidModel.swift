import Foundation

struct LoadUserProfileUidModel: ModelType {
    
    let uid: String
    let nickname: String
    let profileImageCode: String
    let signUpDate: String

    enum CodingKeys: String, CodingKey {
        
        case uid
        case nickname
        case profileImageCode = "profileImage"
        case signUpDate
    }
}
