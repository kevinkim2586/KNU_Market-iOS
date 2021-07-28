import Foundation

//MARK: - 채팅 받아오기 Model

struct ChatResponseModel: Decodable {
    
    let totalPage: String
    let currentPage: String
    let chat: [Chat]
    
    enum CodingKeys: String, CodingKey {
        
        case totalPage
        case currentPage = "curruntPage"
        case chat
    }
}

struct Chat: Decodable {
    
    let chat_uid: Int
    let chat_userUID: String
    let chat_userEmail: String
    let chat_roomUID: String
    let chat_content: String
    let chat_date: String
    
    enum CodingKeys: String, CodingKey {
        
        case chat_uid
        case chat_userUID = "chat_userUid"
        case chat_userEmail
        case chat_roomUID = "chat_room"
        case chat_content = "chat_chat"
        case chat_date
    }
}
