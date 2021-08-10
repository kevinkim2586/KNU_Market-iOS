import Foundation

//MARK: - 공구글 Model

struct ItemDetailModel: Decodable {
    
    let title: String
    let imageUIDs: [String]?
    let location: Int
    let itemDetail: String
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
        case itemDetail = "content"
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

