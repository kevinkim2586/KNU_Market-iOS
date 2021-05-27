import Foundation

struct LoadProfileResponseModel: Decodable {
    
    let id: String
    let nickname: String
    let profileImageCode: String

    enum CodingKeys: String, CodingKey {
        
        case id
        case nickname
        case profileImageCode = "profileImage"
    }
}
