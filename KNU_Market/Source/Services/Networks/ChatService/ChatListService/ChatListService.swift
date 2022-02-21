//
//  ChatListService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/03.
//

import Foundation
import RxSwift

final class ChatListService: ChatListServiceType {

    fileprivate let network: Network<ChatAPI>
    fileprivate let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    init(network: Network<ChatAPI>, userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.network = network
        self.userDefaultsGenericService = userDefaultsGenericService
    }
    
    func fetchJoinedChatList() -> Single<NetworkResultWithArray<Room>> {
        
        return network.requestArrayExcludingSingleValueContainer(.getRoom, type: Room.self)
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
}
