import Foundation

struct Room: ModelType {
    
    let channelId: String
    let title: String
    let headCount: Int
    let createdAt: String
    let postInfo: PostInfo
    let createdBy: CreatedBy
    let channelMembersCount: Int
    
    enum CodingKeys: String, CodingKey {
        
        case channelId
        case title = "name"
        case headCount
        case createdAt
        case postInfo = "post"
        case createdBy
        case channelMembersCount
    }
}

struct PostInfo: ModelType {
    
    let postId: String
    let postFile: FileInfo?
}

