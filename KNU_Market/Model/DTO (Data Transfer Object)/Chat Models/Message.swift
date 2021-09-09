import Foundation
import MessageKit

struct Message: MessageType {
    
    var chat: Chat
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    var heroID: String = ""
}

extension Message {
    
    var messageId: String {
        return String(self.chat.chat_uid)
    }
    
    var date: String {
        return self.sentDate.getDateStringForChatBottomLabel()
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
    
//
//    var heroID: String {
//        return "\(Int.random(in: 0...1000))"
//    }

}

extension Message {
    
    static var defaultValue: Message {
        return Message(chat:
                        Chat(chat_uid: 0,
                             chat_userUID: "",
                             chat_username: "",
                             chat_roomUID: "",
                             chat_content: "",
                             chat_date: ""),
                       sender: Sender(senderId: "",
                                      displayName: ""),
                       sentDate: Date(),
                       kind: .text(""))
    }
}
