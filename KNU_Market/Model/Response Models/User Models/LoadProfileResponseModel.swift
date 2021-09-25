import Foundation

struct LoadProfileResponseModel: Decodable {
    
    let email: String       // email == userID
    let uid: String
    let nickname: String
    let profileImageCode: String
    let isVerified: Bool
    let fcmToken: String

    enum CodingKeys: String, CodingKey {
        
        case email
        case uid
        case nickname
        case profileImageCode = "profileImage"
        case isVerified
        case fcmToken = "fcm"
    }
}

