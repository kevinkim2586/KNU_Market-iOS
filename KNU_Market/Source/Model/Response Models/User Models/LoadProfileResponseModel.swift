import Foundation

//struct LoadProfileResponseModel: ModelType {
//
//    let id: String
//    let emailForPasswordLoss: String
//    let uid: String
//    let nickname: String
//    let profileImageUid: String
//    let isVerified: Bool
//    let fcmToken: String
//    let isReportChecked: Bool
//
//    enum CodingKeys: String, CodingKey {
//
//        case id
//        case emailForPasswordLoss = "email"
//        case uid
//        case nickname
//        case profileImageUid = "profileImage"
//        case isVerified
//        case fcmToken = "fcm"
//        case isReportChecked
//    }
//}

struct LoadProfileResponseModel: ModelType {
    
    let userUid: String
    let username: String        // 로그인할 때 사용하는 아이디
    let displayName: String
    let email: String
    let bannedTo: String?
    let userProfileImage: String?   // 수정


    enum CodingKeys: String, CodingKey {
        
        case userUid = "userId"
        case username
        case displayName = "displayname"
        case email, bannedTo
        case userProfileImage = "userProfile"

    }
}

