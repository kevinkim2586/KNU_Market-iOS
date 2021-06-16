import Foundation

//MARK: - 공구글 Model

struct ItemDetailModel: Decodable {
    
    let title: String
    let imageUIDs: [String]
    let location: Int
    let itemDetail: String
    let totalGatheringPeople: Int
    let nickname: String
    let profileImageUID: String
    
    
    enum CodingKeys: String, CodingKey {
        
        case title
        case imageUIDs = "image"
        case location = "spotCategory"
        case itemDetail = "content"
        case totalGatheringPeople = "recruitment"
        case nickname
        case profileImageUID = "profileImage"
    }
}

