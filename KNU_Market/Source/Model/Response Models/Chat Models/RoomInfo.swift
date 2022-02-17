import Foundation

struct RoomInfo: ModelType {
    let post: Post
    let member: [Member]
}

struct Post: ModelType {
    
    let uuid: String
    let title: String
    let content: String
    let location: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isFull: Bool
    let isCompletelyDone: Bool
    let date: String
    
//    let medias: [Media]
    let user: UploaderInfo
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title, content, location
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currentHeadcount"
        case isFull = "isHeadcountArchived"
        case isCompletelyDone = "isArchived"
        case date = "createDate"
        case user
//        case medias
    }
}

struct UploaderInfo: ModelType {
    let uid: String
}

struct Member: ModelType {
    
    let uid: Int
    let userUID: String
    let postUID: String
    let isBanned: Bool
    let date: String
    
    enum CodingKeys: String, CodingKey {
        
        case uid
        case userUID = "userUid"
        case postUID = "postUid"
        case isBanned = "isbanned"
        case date
    }
}
