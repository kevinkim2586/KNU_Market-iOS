import Foundation

struct LoadProfileResponseModel: ModelType {
    
    let userUid: String
    let username: String        // 로그인할 때 사용하는 아이디
    let displayName: String
    let email: String
    let bannedTo: String?
    let profileUrl: String?
    let userRoleGroup: UserRoleGroup
    
    enum CodingKeys: String, CodingKey {
        case userUid = "userId"
        case username
        case displayName = "displayname"
        case email, bannedTo, profileUrl, userRoleGroup
    }
}

