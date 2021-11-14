import Foundation
import Alamofire

protocol ChatListViewModelDelegate: AnyObject {
    
    func didFetchChatList()
    func failedFetchingChatList(with error: NetworkError)
    
    func didExitPost(at indexPath: IndexPath)
    func failedExitingPost(with error: NetworkError)
    
    func didDeleteAndExitPost(at indexPath: IndexPath)
    func failedDeletingAndExitingPost(with error: NetworkError)
}

class ChatListViewModel {

    weak var delegate: ChatListViewModelDelegate?
    
    var roomList: [Room] = [Room]()
    
    private var isFetchingData: Bool = false
    
    private let chatManager: ChatManager
    private let itemManager: ItemManager
    
    init(chatManager: ChatManager, itemManager: ItemManager) {
        self.chatManager = chatManager
        self.itemManager = itemManager
        createObservers()
    }
}

//MARK: - API Methods

extension ChatListViewModel {
    
    // 전체 채팅 목록 불러오기
    @objc func fetchChatList() {
        
        if isFetchingData { return }
        
        isFetchingData = true
        
        roomList.removeAll()
        User.shared.joinedChatRoomPIDs.removeAll()
        
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
                
                var count = 0
                chatRoom.forEach { chat in
                    User.shared.joinedChatRoomPIDs.append(chat.uuid)
                    
                    if User.shared.chatNotificationList.contains(chat.uuid) {
                        self.roomList.insert(chat, at: 0)
                        count += 1
                    } else {
                        self.roomList.append(chat)
                    }
                }
                
                // 알림 숫자가 안 맞을 시 그냥 초기화
                if count != User.shared.chatNotificationList.count {
                    ChatNotifications.list.removeAll()
                }
                self.isFetchingData = false
                self.delegate?.didFetchChatList()
                
            case .failure(let error):
                self.delegate?.failedFetchingChatList(with: error)
            }
        }
    }
    
    
    // 공구 나가기
    func exitPost(at indexPath: IndexPath) {
        
        let roomPID = roomList[indexPath.row].uuid
        
        chatManager.changeJoinStatus(
            function: .exit,
            pid: roomPID
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.roomList.remove(at: indexPath.row)
                self.delegate?.didExitPost(at: indexPath)
                
            case .failure(let error):
                self.delegate?.failedExitingPost(with: error)
            }
        }
        
    }
    
    // 공구 삭제 -> 내가 작성한 공구글이면 삭제와 동시에 채팅방도 모두 폭파
    func deleteMyPostAndExit(at indexPath: IndexPath) {
        
        let roomPID = self.roomList[indexPath.row].uuid
        
        itemManager.deletePost(uid: roomPID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.roomList.remove(at: indexPath.row)
                self.delegate?.didDeleteAndExitPost(at: indexPath)
                
            case .failure(let error):
                
                self.delegate?.failedDeletingAndExitingPost(with: error)
            }
        }
    }
}

//MARK: - Utility Methods

extension ChatListViewModel {

    func currentRoomIsUserUploaded(at index: Int) -> Bool {
        return roomList[index].userUID == User.shared.userUID
        ? true
        : false
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchChatList),
            name: .getChatList,
            object: nil
        )

    }

}
