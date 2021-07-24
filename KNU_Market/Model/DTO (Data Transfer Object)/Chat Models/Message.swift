import Foundation
import MessageKit

struct Message: MessageType {
    
//    var chat: Chat
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var date: String {
        return self.sentDate.formatToString()
    }
}
