//
//  ChatService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift

#warning("확인 필요 ")

final class ChatService: ChatServiceAPIType {

    fileprivate let network: Network<ChatAPI>
    fileprivate let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    init(network: Network<ChatAPI>, userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.network = network
        self.userDefaultsGenericService = userDefaultsGenericService
    }
    
    func changeJoinStatus(chatFunction: ChatFunction, pid: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.changeJoinStatus(chatFunction: chatFunction, pid: pid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func getRoomInfo(pid: String) -> Single<NetworkResultWithValue<RoomInfo>> {
        
        return network.requestObject(.getRoomInfo(pid: pid), type: RoomInfo.self)
            .map { result in
                switch result {
                case .success(let roomInfo):
                    return .success(roomInfo)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func fetchJoinedChatList() -> Single<NetworkResultWithArray<Room>> {
        
        return network.requestArray(.getRoom, type: Room.self)
            .map { result in
                switch result {
                case .success(let rooms):
                    self.userDefaultsGenericService.set(
                        key: UserDefaults.Keys.joinedChatRoomPIDs,
                        value: rooms.map { $0.channelId }
                    )
                    return .success(rooms)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func getPreviousChats(pid: String, index: Int) -> Single<NetworkResultWithArray<ChatResponseModel>> {
        
        return network.requestArray(.getPreviousChats(pid: pid, index: index), type: ChatResponseModel.self)
            .map { result in
                switch result {
                case .success(let chatResponseModel):
                    return .success(chatResponseModel)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func getNewlyReceivedChats(pid: String, index: Int, lastChatDate: String) -> Single<NetworkResultWithArray<ChatResponseModel>> {
        
        return network.requestArray(.getNewlyReceivedChats(pid: pid, index: index, lastChatDate: lastChatDate), type: ChatResponseModel.self)
            .map { result in
                switch result {
                case .success(let chatResponseModel):
                    return .success(chatResponseModel)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func banUser(userUid: String, room: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.banUser(userUid: userUid, room: room))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
}
