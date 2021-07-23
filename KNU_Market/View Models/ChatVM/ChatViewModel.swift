import Foundation
import Starscream
import MessageKit
import SwiftyJSON
import Alamofire

protocol ChatViewDelegate: AnyObject {
    
    // WebSocket
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
}

//MARK: - WebSocket Methods

extension ChatViewModel {
    
    func connect() {
        
        var request = URLRequest(url: URL(string: Constants.WEB_SOCKET_URL)!)
        
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect() {
        
        let exitText = convertToJSONString(text: "\(User.shared.nickname)님이 채팅방에서 나갔습니다 🧐")
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
            print("❗️ WebSocket has been Disconnected: \(reason) with code: \(code)")
            isConnected = false
            self.delegate?.didDisconnect()
            
            
            
        case .text(let text):
            
            print("✏️ Received Text: \(text)")
            
            let receivedTextInJSON = JSON(parseJSON: text)
            
            let userID = receivedTextInJSON["id"].stringValue
            let chatText = receivedTextInJSON["comment"].stringValue
            let nickname = receivedTextInJSON["nickname"].stringValue
            
            if !isFromCurrentSender(id: userID) {
                self.delegate?.didReceiveChat()
                return
            }
            
            let others = Sender(senderId: userID,
                                displayName: nickname)
            
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
            
        case .error(let reason):
            isConnected = false
            print("❗️ Error in didReceive: \(reason?.localizedDescription)")
            self.delegate?.failedConnection(with: .E000)
            
        default:
            //Default 가 뭐지? 다른 switch case 문 다 실험해보기
            self.delegate?.failedConnection(with: .E000)
         
        }
    }
    
    // 채팅 보내기
    func sendText(_ originalText: String) {
        
        guard isConnected else {
            self.delegate?.reconnectSuggested()
            return
        }
        
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
}

//MARK: - API Methods

extension ChatViewModel {
    
    // 공구 글 참가
    func joinPost() {
        
        ChatManager.shared.joinPost(pid: self.room) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                
                self.connect()
                
            case .failure(let error):
                
                // 이미 참여하고 있는 채팅방이면 기존의 메시지를 불러와야 함
                if error == .E108 {
                    
                    // 이미 참여하고 있는 채팅방의 최신 메시지 받아오기
                    
                    //getChatList
                    
                } else {
                    self.delegate?.failedConnection(with: error)
                }
                
                
            }
        }
    }
        
    
    func exitPost() {
        
        
    }
    
    // 채팅 받아오기
    func getChatList() {
        
        
        
    }
}


//MARK: - Utility Methods

extension ChatViewModel {
    
    func convertToJSONString(text: String) -> String {
        
        let json: JSON = [
            "id": User.shared.id,
            "room": room,
            "comment": text,
            "nickname": User.shared.nickname
        ]
    
        guard let JSONString = json.rawString() else { fatalError() }
        return JSONString
    }

    func isFromCurrentSender(id: String) -> Bool {
        
        if id == User.shared.id { return false }
        else { return true }
    }
    
}

