import Foundation
import MessageKit

struct Message: MessageType {
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var date: String {
        get {
            return sentDate.formatToString()
        }
    }
}
