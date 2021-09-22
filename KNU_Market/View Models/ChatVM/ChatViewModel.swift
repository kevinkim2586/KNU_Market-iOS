import Foundation
import Starscream
import MessageKit
import SDWebImage
import SwiftyJSON
import Alamofire

protocol ChatViewDelegate: AnyObject {
    
    // WebSocket
    func didConnect()
    func didDisconnect()
    func didReceiveChat()
    func reconnectSuggested()
    func failedConnection(with error: NetworkError)
    func didSendText()
    func didReceiveBanNotification()
    
    // API
    func didExitPost()
    func didDeletePost()
    
    func didFetchPreviousChats()
    func didFetchEmptyChat()
    func failedFetchingPreviousChats(with error: NetworkError)

    func failedUploadingImageToServer()
}

class ChatViewModel: WebSocketDelegate {
    
    // Properties
    private var room: String = ""
    private var timer: Timer?

    
    // Room Info (해당 방에 참여하고 있는 멤버 정보 등)
    var roomInfo: RoomInfo?
    var messages = [Message]()
    var mySelf = Sender(senderId: User.shared.userUID,
                        displayName: User.shared.nickname)
    
    private var chatModel: ChatResponseModel?
    private var index: Int = 1
    
    var isFetchingData: Bool = false
    var needsToFetchMoreData: Bool = true
    
    // Socket
    private var socket: WebSocket!
    private let server =  WebSocketServer()
    private var isConnected = false
    private var connectRetryLimit = 5
    private var connectRetryCount = 0
    

    // ChatVC 의 첫 viewDidLoad 이면 collectionView.scrollToLastItem 실행하게끔 위함
    var isFirstViewLaunch: Bool = true
    var isFirstEntranceToChat: Bool

    // Delegate
    weak var delegate: ChatViewDelegate?
    
    // Image Size
    private let imageWidth = 250
    private let imageHeight = 200
    

    init(room: String, isFirstEntrance: Bool) {
        
        self.room = room
        self.isFirstEntranceToChat = isFirstEntrance
        
        resetMessages()
        scheduleSendingGarbageTextWithTimeInterval()
        createObservers()
    }
    
    deinit {
        socket.disconnect()
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
}

//MARK: - WebSocket Methods

extension ChatViewModel {
    
    func connect() {
        
        print("✏️ Trying to connect to WebSocket...")
        
        var request = URLRequest(url: URL(string: Constants.WEB_SOCKET_URL)!)
        request.timeoutInterval = 1000
        
        let pinner = FoundationSecurity(allowSelfSigned: true)
        
        socket = WebSocket(request: request, certPinner: pinner)
        socket.delegate = self
        
        socket.connect() 
        connectRetryCount += 1
    }
    
    func disconnect() {
        socket.disconnect()
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        
        switch event {
    
        case .connected(_):
            
            print("✏️ WebSocket has been Connected!")
             
            isConnected = true
            getRoomInfo()
            connectRetryCount = 0
            self.delegate?.didConnect()
            sendText(Constants.ChatSuffix.emptySuffix)
            
        case .disconnected(let reason, let code):
            print("❗️ WebSocket has been Disconnected: \(reason) with code: \(code)")
            
            isConnected = false
            self.delegate?.didDisconnect()
            
        case .text(let text):
        
            let receivedTextInJSON = JSON(parseJSON: text)
            let nickname = receivedTextInJSON["id"].stringValue
            let userUID = receivedTextInJSON["uuid"].stringValue
            let roomUID = receivedTextInJSON["room"].stringValue
            let chatText = receivedTextInJSON["comment"].stringValue

            let filteredChat = filterChat(text: chatText, userUID: userUID, isFromSocket: true)

            guard filteredChat.chatMessage != Constants.ChatSuffix.emptySuffix else { return }
        
            if isFromCurrentSender(uuid: userUID) {
                self.delegate?.didReceiveChat()
                return
            }
            
            let others = Sender(senderId: userUID,
                                displayName: nickname)
            
            let chat = Chat(chat_uid: Int.random(in: 0...1000),
                            chat_userUID: userUID,
                            chat_username: nickname,
                            chat_roomUID: roomUID,
                            chat_content: filteredChat.chatMessage,
                            chat_date: Date().getDateStringForChatBottomLabel())
            
            if filteredChat.chatType == .text {
                messages.append(Message(chat: chat,
                                             sender: others,
                                             sentDate: Date(),
                                             kind: .text(filteredChat.chatMessage)))
            } else {
                messages.append(Message(chat: chat,
                                             sender: others,
                                             sentDate: Date(),
                                             kind: .photo(ImageItem(url: URL(string: Constants.MEDIA_REQUEST_URL + filteredChat.chatMessage),
                                                                    image: nil,
                                                                    placeholderImage: UIImage(named: "chat_bubble_icon")!,
                                                                    size: CGSize(width: imageWidth, height: imageHeight)))))
            }
            
            self.delegate?.didReceiveChat()
            
        case .reconnectSuggested(_):
            print("❗️ ChatViewModel - Reconnect Suggested")
            
            isConnected = false
        
            self.delegate?.reconnectSuggested()
            sendText(Constants.ChatSuffix.emptySuffix)
            
        case .error(let reason):
            print("❗️ ChatViewModel - Error in didReceive .error: \(String(describing: reason?.localizedDescription))")
            
            isConnected = false
            
            guard connectRetryCount < connectRetryLimit else {
                print("❗️ ChatViewModel - connectRetryCount == 5")
                isConnected = false
                self.delegate?.failedConnection(with: .E000)
                return
            }
            
            connect()

        case .viabilityChanged(_):
            print("❗️ Viability Changed")
            
            isConnected = false
            
            socket.write(ping: Data())
        
        case .cancelled:
            print("❗️ Cancelled")
            
            isConnected = false
            
            disconnect()
      
        case .ping(_):
            print("❗️ PING ACTIVATED")
            
        case .pong(_):
            isConnected = true
        default:
            print("❗️ ChatViewModel - didReceive default ACTIVATED")
            break
        }
    }
    
    // 채팅 보내기
    func sendText(_ originalText: String) {
    
        socket.write(ping: Data())

        guard isConnected else {
            print("❗️ ChatViewModel - sendText() - not Connected!")
            self.delegate?.reconnectSuggested()
            return
        }
        
        let convertedText = convertToJSONString(text: originalText)
        
        socket.write(string: convertedText) {
            
            guard originalText != Constants.ChatSuffix.emptySuffix else {
                return
            }
            
            let filteredChat = self.filterChat(text: originalText)
            
            let chat = Chat(chat_uid: Int.random(in: 0...1000),
                            chat_userUID: User.shared.userUID,
                            chat_username: User.shared.nickname,
                            chat_roomUID: self.room,
                            chat_content: filteredChat.chatMessage,
                            chat_date: Date().getDateStringForChatBottomLabel())
            
            
            if filteredChat.chatType == .text {
                self.messages.append(Message(chat: chat,
                                        sender: self.mySelf,
                                        sentDate: Date(),
                                        kind: .text(filteredChat.chatMessage)))
            } else {
                self.messages.append(Message(chat: chat,
                                        sender: self.mySelf,
                                        sentDate: Date(),
                                        kind: .photo(ImageItem(url: URL(string: Constants.MEDIA_REQUEST_URL + filteredChat.chatMessage),
                                                               image: nil,
                                                               placeholderImage: UIImage(named: "chat_bubble_icon")!,
                                                               size: CGSize(width: self.imageWidth, height: self.imageHeight)))))
            }
            self.delegate?.didSendText()
        }
    }
}

//MARK: - API Methods

extension ChatViewModel {
    
    // 채팅 받아오기
    @objc func getChatList() {
    
        self.isFetchingData = true
        
        ChatManager.shared.getResponseModel(function: .getChat,
                                            method: .get,
                                            pid: self.room,
                                            index: self.index,
                                            expectedModel: ChatResponseModel.self) { [weak self] result in
            
            guard let self = self else { return }
        
            switch result {
            case .success(let chatResponseModel):
                
                if chatResponseModel.chat.isEmpty {
                    self.isFetchingData = false
                    self.needsToFetchMoreData = false
                    self.delegate?.didFetchEmptyChat()
                    return
                }
                
                self.chatModel?.chat.insert(contentsOf: chatResponseModel.chat, at: 0)
                
                for chat in chatResponseModel.chat {
                    
                    let chatText = chat.chat_content
                    let senderUID = chat.chat_userUID
                
                    let filteredChat = self.filterChat(text: chatText, userUID: senderUID)
                    
                    guard filteredChat.chatMessage != Constants.ChatSuffix.emptySuffix else { continue }
                
                    // 내 채팅이 아니면
                    if chat.chat_userUID != User.shared.userUID {
                        
                        let others = Sender(senderId: chat.chat_userUID,
                                            displayName: chat.chat_username)
                        
                        
                        if filteredChat.chatType == .text {
                            self.messages.insert(Message(chat: chat,
                                                         sender: others,
                                                         sentDate: chat.chat_date.convertStringToDate(),
                                                         kind: .text(filteredChat.chatMessage)),
                                                 at: 0)
                        } else {
                            self.messages.insert(Message(chat: chat,
                                                         sender: others,
                                                         sentDate: chat.chat_date.convertStringToDate(),
                                                         kind: .photo(ImageItem(url: URL(string: Constants.MEDIA_REQUEST_URL + filteredChat.chatMessage),
                                                                                image: nil,
                                                                                placeholderImage: UIImage(named: "chat_bubble_icon")!,
                                                                                size: CGSize(width: self.imageWidth, height: self.imageHeight)))),
                                                 at: 0)
                        }

                    }
                    
                    // 내 채팅이면
                    else {
                        
                        if filteredChat.chatType == .text {
                            self.messages.insert(Message(chat: chat,
                                                         sender: self.mySelf,
                                                         sentDate: chat.chat_date.convertStringToDate(),
                                                         kind: .text(filteredChat.chatMessage)),
                                                 at: 0)
                        } else {
                            self.messages.insert(Message(chat: chat,
                                                         sender: self.mySelf,
                                                         sentDate: chat.chat_date.convertStringToDate(),
                                                         kind: .photo(ImageItem(url: URL(string: Constants.MEDIA_REQUEST_URL + filteredChat.chatMessage),
                                                                                image: nil,
                                                                                placeholderImage: UIImage(named: "chat_bubble_icon")!,
                                                                                size: CGSize(width: self.imageWidth, height: self.imageHeight)))),
                                                 at: 0)
                        }
                    }
                }
                
                self.isFetchingData = false
                self.index += 1
                self.delegate?.didFetchPreviousChats()
                
            case .failure(let error):
                self.isFetchingData = false
                self.delegate?.failedFetchingPreviousChats(with: error)
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
                self.getRoomInfo()
            case .failure(let error):
                // 이미 참여하고 있는 채팅방이면 기존의 메시지를 불러와야함
                if error == .E108 {
                    self.connect()
                    self.getRoomInfo()
                } else {
                    print("❗️ ChatViewModel - joinPost ERROR")
                    self.delegate?.failedConnection(with: error)
                }
            }
        }
    }
    
    // 공구글 나오기
    @objc func exitPost() {
        
        sendText(Constants.ChatSuffix.emptySuffix)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.sendText("\(User.shared.nickname)\(Constants.ChatSuffix.exitSuffix)")
            dismissProgressBar()
        }
    }
    
    func outPost() {
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
    
    
    @objc func sendBanMessageToSocket(notification: Notification) {
        
        sendText(Constants.ChatSuffix.emptySuffix)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            
            dismissProgressBar()
            if let object = notification.object as? [String : String] {
                if let uid = object["uid"], let nickname = object["nickname"] {
                    self.sendText("\(nickname)님이 퇴장 당했습니다.\(uid)\(Constants.ChatSuffix.rawBanSuffix)")
                }
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
                self.roomInfo = roomInfoModel
            case .failure(let error):
                print("❗️ChatViewModel - getRoomInfo FAILED with error: \(error.errorDescription)")
            }
            
        }
    }
    
    // 글 작성자가 ChatVC 내에서 공구글을 삭제하고자 할 때 실행
    @objc func deletePost() {
        
        ItemManager.shared.deletePost(uid: room) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                self.delegate?.didDeletePost()
            case .failure(let error):
                self.delegate?.failedConnection(with: error)
            }
        }
    }
    
    func uploadImage(imageData: Data) {
        
        MediaManager.shared.uploadImage(with: imageData) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let imageUID):
                
                self.sendText("\(imageUID)" + Constants.ChatSuffix.imageSuffix)
                
            case .failure(_):
                self.delegate?.failedUploadingImageToServer()
            }
            
        }
    }
}


//MARK: - Utility Methods

extension ChatViewModel {
    
    func scheduleSendingGarbageTextWithTimeInterval() {
        
        timer =  Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] timer in
            self?.sendText(Constants.ChatSuffix.emptySuffix)
        }
    }
    
    func convertToJSONString(text: String) -> String {
        
        let json: JSON = [
            "id": User.shared.nickname,
            "uuid": User.shared.userUID,
            "room": room,
            "comment": text
        ]
    
        guard let JSONString = json.rawString() else { return Constants.ChatSuffix.emptySuffix }
        return JSONString
    }

    func isFromCurrentSender(uuid: String) -> Bool {
       return uuid == User.shared.userUID ? true : false
    }
    
    var postUploaderUID: String {
        return roomInfo?.post.user.uid ?? ""
    }
    
    func filterChat(text: String, userUID: String? = nil, isFromSocket: Bool = false) -> FilteredChat {
        
        if userUID != nil {
            if User.shared.bannedChatMembers.contains(userUID!) {
                return FilteredChat(chatMessage: Constants.ChatSuffix.emptySuffix, chatType: .text)
            }
        }
        
        if text.contains(Constants.ChatSuffix.enterSuffix) {
            return FilteredChat(chatMessage: text.replacingOccurrences(of: Constants.ChatSuffix.rawEnterSuffix, with: "🎉"), chatType: .text)
       
        } else if text == "\(User.shared.nickname)\(Constants.ChatSuffix.exitSuffix)" && isFromSocket {
            outPost()
            return FilteredChat(chatMessage: Constants.ChatSuffix.emptySuffix, chatType: .text)
            
        } else if text.contains(Constants.ChatSuffix.exitSuffix) {
            return FilteredChat(chatMessage: text.replacingOccurrences(of: Constants.ChatSuffix.rawExitSuffix, with: "🏃"), chatType: .text)
            
        } else if text.contains("퇴장 당했습니다.\(User.shared.userUID)\(Constants.ChatSuffix.rawBanSuffix)") {
            self.delegate?.didReceiveBanNotification()
            return FilteredChat(chatMessage: Constants.ChatSuffix.emptySuffix, chatType: .text)

        } else if text.contains(Constants.ChatSuffix.rawBanSuffix) {
            return FilteredChat(chatMessage: Constants.ChatSuffix.usedBanSuffix, chatType: .text)
            
        } else if text.contains(Constants.ChatSuffix.imageSuffix) {
            
            let imageUID = text[0..<22]
            return FilteredChat(chatMessage: imageUID, chatType: .photo)
            
        } else if text.contains("_SUFFIX") {
            return FilteredChat(chatMessage: "[아직 지원하지 않는 형식의 메시지입니다. 확인하시려면 앱을 최신 버전으로 업데이트 해주세요.]", chatType: .text)
        }
        
        else {
            return FilteredChat(chatMessage: text, chatType: .text)
        }
    }
    
    func resetMessages() {
        chatModel = nil
        messages.removeAll()
        index = 1
    }
    
    @objc func resetAndReconnect() {
        resetMessages()
        connect()
    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(exitPost),
                                               name: .didChooseToExitPost,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deletePost),
                                               name: .didChooseToDeletePost,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sendBanMessageToSocket),
                                               name: .didBanUser,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getChatList),
                                               name: .didDismissPanModal,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resetAndReconnect),
                                               name: .getChat,
                                               object: nil)
    }

}
