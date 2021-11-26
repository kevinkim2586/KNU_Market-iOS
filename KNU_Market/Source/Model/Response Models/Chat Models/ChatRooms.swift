import Foundation

struct ChatRooms: Decodable {
    
    let postUID: String
    
    enum CodingKeys: String, CodingKey {
        case postUID = "postUid"
    }
}
