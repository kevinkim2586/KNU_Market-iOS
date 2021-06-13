import Foundation

//MARK: - 공구글 리스트 Model

struct ItemListModel: Decodable {
    
    let uuid: String
    let title: String
    let imageUIDs: String
    let location: Int
    let totalGatheringPeople: Int
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title
        case imageUIDs = "medias"
        case location
        case totalGatheringPeople = "maxHeadcount"
    }

}
