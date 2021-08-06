import Foundation
import Alamofire

protocol ChatListViewModelDelegate: AnyObject {
    
    func didFetchChatList()
    func failedFetchingChatList(with error: NetworkError)
    
    func didExitPost()
    func failedExitingPost(with error: NetworkError)
    
    func didDeleteAndExitPost()
    func failedDeletingAndExitingPost(with error: NetworkError)
  
}

class ChatListViewModel {

    weak var delegate: ChatListViewModelDelegate?
    
    var roomList: [Room] = [Room]()
    
}

//MARK: - API Methods

extension ChatListViewModel {
    
    // 전체 채팅 목록 불러오기
    func fetchChatList() {
        
        self.roomList.removeAll()
        
        ChatManager.shared.getResponseModel(function: .getRoom,
                                       method: .get,
                                       pid: nil,
                                       index: nil,
                                       expectedModel: [Room].self) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let chatRoom):
        
                chatRoom.forEach { chat in
                    User.shared.joinedChatRoomPIDs.append(chat.uuid)
                }
                
                self.roomList.append(contentsOf: chatRoom)
                self.delegate?.didFetchChatList()
                
            case .failure(let error):
                self.delegate?.failedFetchingChatList(with: error)
            }
        }
    }

    
    // 공구 나가기
    // 수정: completion handler 말고 delegate 으로 하기 
    func exitPost(at index: Int,
                  completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let roomPID = self.roomList[index].uuid
        
            ChatManager.shared.changeJoinStatus(function: .exit,
                                                pid: roomPID) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.roomList.remove(at: index)
                    completion(.success(true))
                
                case .failure(let error):
                    
                    completion(.failure(error))

                }
            }
        
    }
    
    // 공구 삭제 -> 내가 작성한 공구글이면 삭제와 동시에 채팅방도 모두 폭파
    func deleteAndExitPost() {
        
        
    }
    
 
    
    
}

//MARK: - Utility Methods

extension ChatListViewModel {

    func currentRoomIsUserUploaded(at index: Int) -> Bool {
        
        if self.roomList[index].userUID == User.shared.userUID {
            return true
        } else {
            return false
        }
    }
    
}
