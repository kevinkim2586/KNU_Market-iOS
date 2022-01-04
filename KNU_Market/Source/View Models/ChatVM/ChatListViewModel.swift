import Foundation
import Alamofire

protocol ChatListViewModelDelegate: AnyObject {
    func didFetchChatList()
    func failedFetchingChatList(with error: NetworkError)
}

class ChatListViewModel {

    weak var delegate: ChatListViewModelDelegate?
    
    var roomList: [Room] = [Room]()
    
    private var isFetchingData: Bool = false
    
    private let chatManager: ChatManager
    private let postManager: PostManager        // 제거 예정 더 이상 필요 X
    
    init(chatManager: ChatManager, postManager: PostManager) {
        self.chatManager = chatManager
        self.postManager = postManager
    }
}

//MARK: - API Methods

extension ChatListViewModel {
    
    // 전체 채팅 목록 불러오기
    @objc func fetchChatList() {
        
        if isFetchingData { return }
        
        isFetchingData = true

        chatManager.getResponseModel(
            function: .getRoom,
            method: .get,
            pid: nil,
            index: nil,
            expectedModel: [Room].self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let chatRoom):
                
                self.roomList.removeAll()
                
//                let uidList = chatRoom.map { $0.uuid }
                // 1. sort based on notifications
                // 2.
                
                User.shared.joinedChatRoomPIDs = chatRoom.map { $0.uuid }
                
                var count = 0
                chatRoom.forEach { chat in

                    
                    if User.shared.chatNotificationList.contains(chat.uuid) {
                        self.roomList.insert(chat, at: 0)
                        count += 1
                    } else {
                        self.roomList.append(chat)
                    }
                }
                
                // 알림 숫자가 안 맞을 시 그냥 초기화
//                if count != User.shared.chatNotificationList.count {
//                    ChatNotifications.list.removeAll()
//                }
                self.isFetchingData = false
                self.delegate?.didFetchChatList()
                
            case .failure(let error):
                self.delegate?.failedFetchingChatList(with: error)
            }
        }
    }

}

