import Foundation
import MessageKit

struct Message: MessageType {
    
    var chat: Chat
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    
    var messageId: String {
        return String(self.chat.chat_uid)
    }
    
    var date: String {
        return self.sentDate.getFormattedDate()
    }
    
    var usernickname: String {
        return self.chat.chat_username
    }

    var userUID: String {
        return self.chat.chat_userUID
    }
    
    var chatRoomUID: String {
        return self.chat.chat_roomUID
    }
    
    var chatContent: String {
        return self.chat.chat_content
    }
    
}
