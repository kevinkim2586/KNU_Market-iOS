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
    
    // API
    func didExitPost()
    
    func didFetchChats()
    func failedFetchingChats(with error: NetworkError)
    
}

class ChatViewModel: WebSocketDelegate {
    
    // Socket
    private var socket: WebSocket!
    private var isConnected = false
    private let server =  WebSocketServer()
    
    private var room: String = ""
    
    var messages = [Message]()
    var mySelf = Sender(senderId: User.shared.userUID,
                        displayName: User.shared.nickname)
    
    
    
    var chatModel: ChatResponseModel?
    var index: Int = 1
    
    
    var isFetchingData: Bool = false
    
    // ChatVC 의 첫 viewDidLoad 이면 collectionView.scrollToLastItem 실행하게끔 위함
    var isFirstViewLaunch: Bool = true
    
    
    // Room Info (해당 방에 참여하고 있는 멤버 정보 등)
    var roomInfo: RoomInfo?

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
    
    // 수정 필요
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
            
            let nickname = receivedTextInJSON["id"].stringValue
            let userUID = receivedTextInJSON["uuid"].stringValue
            let roomUID = receivedTextInJSON["room"].stringValue
            let chatText = receivedTextInJSON["comment"].stringValue
        
            if !isFromCurrentSender(uuid: userUID) {
                self.delegate?.didReceiveChat()
                return
            }
            
            // 그리고 받은 text 가 중복인지 아닌지 확인해서 중복이면 띄우지 말아야함
            // 중복인지 아닌지는 chat_uid 를 확인하면 될듯하다
            
            let others = Sender(senderId: userUID,
                                displayName: nickname)
            
            let chat = Chat(chat_uid: Int.random(in: 0...1000),
                            chat_userUID: userUID,
                            chat_username: nickname,
                            chat_roomUID: roomUID,
                            chat_content: chatText,
                            chat_date: Date().getFormattedDate())
            
            self.messages.append(
                Message(chat: chat,
                        sender: others,
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
            
            let chat = Chat(chat_uid: Int.random(in: 0...1000),
                            chat_userUID: User.shared.userUID,
                            chat_username: User.shared.nickname,
                            chat_roomUID: self.room,
                            chat_content: convertedText,
                            chat_date: Date().getFormattedDate())
            
            self.messages.append(
                Message(chat: chat,
                        sender: self.mySelf,
                        sentDate: Date(),
                        kind: .text(originalText))
            )
        }
    }
}

//MARK: - API Methods

extension ChatViewModel {
    
    // 채팅 받아오기
    func getChatList() {
        
        self.isFetchingData = true
        
        ChatManager.shared.getResponseModel(function: .getChat,
                                            method: .get,
                                            pid: self.room,
                                            index: self.index,
                                            expectedModel: ChatResponseModel.self) { [weak self] result in
            
            guard let self = self else { return }

            switch result {
            case .success(let chatResponseModel):

                self.isFetchingData = false
                self.index += 1
                
                self.chatModel?.chat.insert(contentsOf: chatResponseModel.chat, at: 0)

                chatResponseModel.chat.forEach { chat in
                    
                    // 내 채팅이 아니면
                    if chat.chat_userUID != User.shared.userUID {
                        
                        let others = Sender(senderId: chat.chat_userUID,
                                            displayName: chat.chat_username)
                        
                        self.messages.insert(Message(chat: chat,
                                                     sender: others,
                                                     sentDate: chat.chat_date.convertStringToDate(),
                                                     kind: .text(chat.chat_content)),
                                             at: 0)
                    } else {
                        
                        self.messages.insert(Message(chat: chat,
                                                     sender: self.mySelf,
                                                     sentDate: chat.chat_date.convertStringToDate(),
                                                     kind: .text(chat.chat_content)),
                                             at: 0)
                    }
                }
                
                self.delegate?.didFetchChats()
                
            case .failure(let error):

                self.delegate?.failedFetchingChats(with: error)

            }
        }
        
        
    }
    
    // 공구글 참가
    func joinPost() {
        
        ChatManager.shared.changeJoinStatus(function: .join,
                                            pid: self.room) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.connect()
                
            case .failure(let error):
                
                print("❗️ ChatViewModel - joinPost error: \(error)")
                
                // 이미 참여하고 있는 채팅방이면 기존의 메시지를 불러와야 함
                if error == .E108 {
                    
                    //TODO: connect를 하고 getChatList?
                    
                    self.getChatList()
                    self.getRoomInfo()
                    // 이미 참여하고 있는 채팅방의 최신 메시지 받아오기
                    
          
                    
                } else {
                    self.delegate?.failedConnection(with: error)
                }
            }
        }
    }
    
    // 공구글 나오기
    func exitPost() {
        
        ChatManager.shared.changeJoinStatus(function: .exit,
                                            pid: self.room) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.delegate?.didExitPost()
            case .failure(let error):
                self.delegate?.failedConnection(with: error)
            }
        }
    }
    
    // 채팅 참여 인원 정보 불러오기
    func getRoomInfo() {
        
        ChatManager.shared.getResponseModel(function: .getRoomInfo,
                                            method: .get,
                                            pid: self.room,
                                            index: nil,
                                            expectedModel: RoomInfo.self) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let roomInfoModel):
                print("✏️ ChatViewModel - getRoomInfo SUCCESS")
                self.roomInfo = roomInfoModel
            case .failure(let error):
                print("✏️ ChatViewModel - getRoomInfo FAILED with error: \(error.errorDescription)")
            }
            
        }
        
        
    }
}


//MARK: - Utility Methods

extension ChatViewModel {
    
    func convertToJSONString(text: String) -> String {
        
        let json: JSON = [
            "id": User.shared.nickname,
            "uuid": User.shared.userUID,
            "room": room,
            "comment": text
        ]
    
        guard let JSONString = json.rawString() else { fatalError() }
        return JSONString
    }

    func isFromCurrentSender(uuid: String) -> Bool {
        
       return uuid == User.shared.userUID ? false : true
        
//        if uuid == User.shared.userUID { return false }
//        else { return true }
    }
    
}

