import Foundation

struct Room: Decodable {
    
    let uuid: String
    let title: String
    let content: String
    let location: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isArchived: Int
    let date: String
    let imageCode: String?
    let userUID: String
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title, content, location
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currenHheadcount"
        case isArchived, date
        case imageCode = "images"
        case userUID = "userUid"
    }
    
}
