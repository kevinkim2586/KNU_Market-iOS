import Foundation

struct Room: Decodable {
    
    let uuid: String
    let title: String
    let content: String
    let location: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isCompletelyDone: Int
    let date: String
    let imageCodes: [String]
    let userUID: String
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title, content, location
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currentHeadcount"
        case isCompletelyDone = "isArchived"
        case date
        case imageCodes = "images"
        case userUID = "userUid"
    }
    
}
