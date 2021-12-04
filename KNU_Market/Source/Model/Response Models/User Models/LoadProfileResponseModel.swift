import Foundation

struct LoadProfileResponseModel: Decodable {
    
    let id: String
    let emailForPasswordLoss: String
    let uid: String
    let nickname: String
    let profileImageCode: String
    let isVerified: Bool
    let fcmToken: String
    let isReportChecked: Bool

    enum CodingKeys: String, CodingKey {
        
        case id
        case emailForPasswordLoss = "email"
        case uid
        case nickname
        case profileImageCode = "profileImage"
        case isVerified
        case fcmToken = "fcm"
        case isReportChecked
    }
}

