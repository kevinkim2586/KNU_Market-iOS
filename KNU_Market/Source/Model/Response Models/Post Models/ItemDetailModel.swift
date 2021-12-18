import Foundation

//MARK: - 공구글 Model

struct PostDetailModel: ModelType {
    
    let title: String
    let imageUIDs: [String]?
    let location: Int
    let postDetail: String
    let viewCount: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isFull: Bool
    let isCompletelyDone: Bool
    let nickname: String
    let profileImageUID: String
    let date: String
    let userUID: String
    
    enum CodingKeys: String, CodingKey {
        
        case title
        case imageUIDs = "images"
        case location = "spotCategory"
        case postDetail = "content"
        case viewCount  = "viewCount"
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currentHeadcount"
        case isFull = "isHeadcountArchived"
        case isCompletelyDone = "isArchived"
        case nickname
        case profileImageUID = "profileImage"
        case date
        case userUID = "userUid"
    }
}

