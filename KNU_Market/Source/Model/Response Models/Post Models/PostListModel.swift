import Foundation

//MARK: - 공구글 리스트 Model

struct PostListModel: Decodable, ModelType {

//    let totalNumberOfPosts: Int
    let posts: [PostModel]
    
//    init(from decoder: Decoder) throws {
//        var container = try decoder.unkeyedContainer()
//        self.totalNumberOfPosts = try container.decode(Int.self)
//        self.posts = try container.decode([PostModel].self)
//    }

//    enum CodingKeys: String, CodingKey {
////        case totalNumberOfPosts = ""
//        case posts
//    }
}

struct PostModel: Decodable, ModelType {
    let postID, channelID, title: String
    let location, headCount, currentHeadCount: Int
    let createdAt: String
    let recruitedAt: String?
    let isRecruited: Int        // 인원 모집 완료 여부
    let price: Int?
    let shippingFee: Int?
    let postFile: FileInfo?

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case channelID = "channelId"
        case title, location, headCount, currentHeadCount, createdAt, recruitedAt, isRecruited, price, shippingFee, postFile
    }
}

// MARK: - PostFile
struct FileInfo: Decodable, ModelType {
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
