import Foundation

//MARK: - 공구글 리스트 Model

struct ItemListModel: Decodable {
    
    let uuid: String
    let title: String
    let imageUID: String?
    let location: Int
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let date: String
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title
        case imageUID = "image"
        case location = "spotCategory"
        case totalGatheringPeople = "maxHeadcount"
        case currentlyGatheredPeople = "currentHeadcount"
        case date
        
    }

}
