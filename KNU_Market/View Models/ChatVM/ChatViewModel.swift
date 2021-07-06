import Foundation
import Starscream
import MessageKit
import SwiftyJSON

protocol ChatViewDelegate: AnyObject {
    
    
    func didConnect()
    func didDisconnect()
    func didReceiveChat()
    
    func reconnectSuggested()
    func failedConnection(with error: NetworkError)
}

class ChatViewModel: WebSocketDelegate {
    
    // Socket
    var socket: WebSocket!
    var isConnected = false
    let server =  WebSocketServer()
    
    var room: String = ""
    
    var messages = [Message]()
    var mySelf = Sender(senderId: User.shared.id,
                        displayName: User.shared.nickname)

    // Delegate
    weak var delegate: ChatViewDelegate?

    init(room: String) {
        
        self.room = room
    }
    
    //MARK: - Methods
    
    func connect() {
        
        var request = URLRequest(url: URL(string: Constants.WEB_SOCKET_URL)!)
        
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        
        let exitText = convertToJSONString(text: "\(User.shared.id)님이 채팅방에서 나갔습니다.")
        socket.write(string: exitText) {
            self.socket.disconnect()
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        switch event {
        
        case .connected(_):
            isConnected = true
            self.delegate?.didConnect()
            print("✏️ WebSocket has been Connected!")
            
        case .disconnected(let reason, let code):
            isConnected = false
            self.delegate?.didDisconnect()
            
            print("❗️ WebSocket has been Disconnected: \(reason) with code: \(code)")
            
        case .text(let text):
            
            print("✏️ Received Text: \(text)")
            
            let receivedTextInJSON = JSON(parseJSON: text)
            
            let userID = receivedTextInJSON["id"].stringValue
            let chatText = receivedTextInJSON["comment"].stringValue
            
            if !checkIfIDIsUsersOwn(id: userID) { break }
            
            let others = Sender(senderId: userID,
                                displayName: userID)
            
            self.messages.append(
                Message(
                    sender: others,
                    messageId: UUID().uuidString,
                    sentDate: Date(),
                    kind: .text(chatText))
            )
            self.delegate?.didReceiveChat()
         
            
        case .reconnectSuggested(_):
            self.delegate?.reconnectSuggested()
            
        case .error(_):
            isConnected = false
            print("❗️ Error in didReceive")
            self.delegate?.failedConnection(with: .E000)
            
        default:
            self.delegate?.failedConnection(with: .E000)
         
        }
    }

    func sendText(_ originalText: String) {
        
        let convertedText = convertToJSONString(text: originalText)
        
        socket.write(string: convertedText) {
            self.messages.append(
                Message(
                    sender: self.mySelf,
                    messageId: UUID().uuidString,
                    sentDate: Date(),
                    kind: .text(originalText))
            )
        }
    }
    
    
    
    func convertToJSONString(text: String) -> String {
        
        let json: JSON = [
            "id": User.shared.id,
            "room": room,
            "comment": text
        ]
    
        guard let JSONString = json.rawString() else { fatalError() }
        
        print("✏️ Converted JSONString: \(JSONString)")
        return JSONString
    }

    func checkIfIDIsUsersOwn(id: String) -> Bool {
        
        if id == User.shared.id { return false }
        else { return true }
    }

}

