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
    let createdAt: String
    let recruitedAt: String?
    let isRecruited: Int
    let price: Int?
    let shippingFee: Int?
    let referenceUrl: String?
    let createdBy: CreatedBy
    let postFile: FileInfo?

    enum CodingKeys: String, CodingKey {
        
        case uuid = "postId"
        case channelId
        case title
        case postDetail = "content"
        case location
        case totalGatheringPeople = "headCount"
        case currentlyGatheredPeople = "currentHeadCount"
        case viewCount  = "viewCount"
        case createdAt
        case recruitedAt
        case isRecruited
        case price
        case shippingFee
        case referenceUrl
        case createdBy
        case postFile
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
            createdAt: "",
            recruitedAt: nil,
            isRecruited: 0,
            price: nil,
            shippingFee: nil,
            referenceUrl: nil,
            createdBy: CreatedBy(userId: "", displayName: "-", profileUrl: nil),
            postFile: nil
        )
    }
}


struct CreatedBy: ModelType {
    
    let userId: String
    let displayName: String?
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case displayName = "displayname"
        case profileUrl
    }
}
