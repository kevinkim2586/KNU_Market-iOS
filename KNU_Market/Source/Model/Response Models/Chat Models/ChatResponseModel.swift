import Foundation

//MARK: - 채팅 받아오기 Model

struct ChatResponseModel: ModelType {
    
    let totalPage: String
    let currentPage: String
    var chat: [Chat]
    
    enum CodingKeys: String, CodingKey {
        
        case totalPage
        case currentPage = "curruntPage"
        case chat
    }
}

struct Chat: ModelType {
    
    let chat_uid: Int
    let chat_userUID: String
    let chat_username: String
    let chat_roomUID: String
    let chat_content: String
    let chat_date: String
    
    enum CodingKeys: String, CodingKey {
        
        case chat_uid
        case chat_userUID = "chat_userUid"
        case chat_username = "chat_userName"
        case chat_roomUID = "chat_room"
        case chat_content = "chat_chat"
        case chat_date
    }
}
