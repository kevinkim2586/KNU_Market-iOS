import Foundation

struct LoadProfileResponseModel: ModelType {
    
    let id: String
    let emailForPasswordLoss: String
    let uid: String
    let nickname: String
    let profileImageUid: String
    let isVerified: Bool
    let fcmToken: String
    let isReportChecked: Bool

    enum CodingKeys: String, CodingKey {
        
        case id
        case emailForPasswordLoss = "email"
        case uid
        case nickname
        case profileImageUid = "profileImage"
        case isVerified
        case fcmToken = "fcm"
        case isReportChecked
    }
}

