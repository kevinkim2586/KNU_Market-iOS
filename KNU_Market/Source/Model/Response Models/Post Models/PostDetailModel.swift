import Foundation

//MARK: - 공구글 Model


struct PostDetailModel: ModelType {
    
    let uuid: String
    let title: String
    let imageUIDs: [String]?
    let price: Int?
    let referenceUrl: String?
    let shippingFee: Int?
    let postDetail: String
    let viewCount: Int
    let location: Int?
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let isFull: Bool
    let isCompletelyDone: Bool
    let nickname: String
    let profileImageUID: String
    let date: String
    let userUID: String
    
    enum CodingKeys: String, CodingKey {
        
        case uuid = "UUID"
        case title
        case imageUIDs = "images"
        case price, referenceUrl, shippingFee
        case location
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
    
    static func getDefaultState() -> PostDetailModel {
        return PostDetailModel(
            uuid: "",
            title: "",
            imageUIDs: nil,
            price: 0,
            referenceUrl: nil,
            shippingFee: nil,
            postDetail: "로딩 중..",
            viewCount: 0,
            location: nil,
            totalGatheringPeople: 2,
            currentlyGatheredPeople: 1,
            isFull: false,
            isCompletelyDone: false,
            nickname: "",
            profileImageUID: "default",
            date: "",
            userUID: ""
        )
    }
}

