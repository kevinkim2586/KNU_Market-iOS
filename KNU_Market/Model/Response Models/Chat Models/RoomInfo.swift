import Foundation

struct RoomInfo: Decodable {
    
    let post: Post
    let member: [Member]
}

struct Post: Decodable {
    
    let uuid: String
    let title: String
    let content: String
    let location: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isArchived: Bool
    let date: String
    
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title, content, location
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currunHheadcount"
        case isArchived, date
        
    }
}

struct Member: Decodable {
    
    let uid: Int
    let userUID: String
    let postUID: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        
        case uid
        case userUID = "userUid"
        case postUID = "postUid"
        case date
    }
}
