import Foundation

//MARK: - 공구글 리스트 Model

struct PostListModel: Decodable, ModelType {

//    let totalNumberOfPosts: Int?
    let posts: [PostModel]

    enum CodingKeys: String, CodingKey {
//        case totalNumberOfPosts = ""
        case posts
    }
}

struct PostModel: Decodable, ModelType {
    let postID, channelID, title: String
    let location, headCount, currentHeadCount: Int
    let createdAt: String
    let recruitedAt: String?
    let isRecruited: Int        // 인원 모집 완료 여부
    let price: Int?
    let shippingFee: Int?
    let postFile: PostFile?

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case channelID = "channelId"
        case title, location, headCount, currentHeadCount, createdAt, recruitedAt, isRecruited, price, shippingFee, postFile
    }
}

// MARK: - PostFile
struct PostFile: Decodable, ModelType {
    let fileFolderID: String
    let files: [File]

    enum CodingKeys: String, CodingKey {
        case fileFolderID = "fileFolderId"
        case files
    }
}

// MARK: - File
struct File: Decodable, ModelType {
    let location: String
}








//struct PostListModel: ModelType {
//
//    let uuid: String
//    let title: String
//    let totalGatheringPeople: Int
//    let currentlyGatheredPeople: Int
//    let price: Int?
//    let referenceUrl: String?
//    let shippingFee: Int?
//    let isFull: Bool
//    let isCompletelyDone: Bool
//    let date: String
//    let imageUIDs: [Media]
//    let userInfo: UserInfo?
//
//    enum CodingKeys: String, CodingKey {
//
//        case uuid = "UUID" //
//        case title
//        case totalGatheringPeople = "maxHeadcount"
//        case currentlyGatheredPeople = "currentHeadcount"
//        case price, referenceUrl, shippingFee
//        case isFull = "isHeadcountArchived"
//        case isCompletelyDone = "isArchived"
//        case date = "createDate"
//        case imageUIDs = "medias"
//        case userInfo = "user"
//
//    }
//}
//
//struct Media: ModelType {
//
//    let uid: String
//    let path: String
//    let userUID: String
//    let date: String
//
//    enum CodingKeys: String, CodingKey {
//
//        case uid, path, date
//        case userUID = "userUid"
//    }
//}
//
//struct UserInfo: ModelType {
//
//    let userUID: String
//
//    enum CodingKeys: String, CodingKey {
//        case userUID = "uid"
//    }
//}
