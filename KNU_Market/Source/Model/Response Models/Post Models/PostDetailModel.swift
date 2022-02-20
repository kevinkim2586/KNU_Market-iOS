import Foundation

//MARK: - 공구글 Model

struct PostDetailModel: ModelType {
    
    let uuid: String
    let channelId: String
    let title: String
    let postDetail: String
    let location: Int?
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let viewCount: Int
    let date: String
    let recruitedAt: String?
    let price: Int?
    let shippingFee: Int?
    let createdBy: CreatedBy
    
//    let referenceUrl: String?

    enum CodingKeys: String, CodingKey {
        
        case uuid = "postId"
        case channelId
        case title
        case postDetail = "content"
        case location
        case totalGatheringPeople = "headCount"
        case currentlyGatheredPeople = "currentHeadCount"
        case viewCount  = "viewCount"
        case date
        case recruitedAt
        case price
        case shippingFee
        case createdBy
    }
    
    static func getDefaultState() -> PostDetailModel {
        return PostDetailModel(
            uuid: "",
            channelId: "",
            title: "",
            postDetail: "로딩 중..",
            location: nil,
            totalGatheringPeople: 2,
            currentlyGatheredPeople: 1,
            viewCount: 0,
            date: "",
            recruitedAt: nil,
            price: nil,
            shippingFee: nil,
            createdBy: CreatedBy(userId: "", displayName: "-")
        )
    }
}


struct CreatedBy: ModelType {
    let userId: String
    let displayName: String
    
    enum CodingKeys: String, CodingKey {
        case userId
        case displayName = "displayname"
    }
}
