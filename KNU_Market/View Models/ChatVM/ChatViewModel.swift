import Foundation
import Starscream
import MessageKit
import SwiftyJSON

protocol ChatViewDelegate: AnyObject {
    
    
    func didConnect()
    func didDisconnect()
    func didReceiveChat(_ text: String)
    
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
    var otherParticipant: [Sender]?
    
    
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
    
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        switch event {
        
        case .connected(let headers):
            isConnected = true
            self.delegate?.didConnect()
            print("websocket is connected: \(headers)")
            
        case .disconnected(let reason, let code):
            isConnected = false
            self.delegate?.didDisconnect()
            print("websocket is disconnected: \(reason) with code: \(code)")
            
        case .text(let text):
            // JSON parsing 이루어져야할듯
            
            
            
            
            self.delegate?.didReceiveChat(text)
            print("Received text: \(text)")
            
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
            
            print("✏️ sendText completed")
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
        
        print("✏️ JSONString: \(JSONString)")
        return JSONString
    }
    
}

