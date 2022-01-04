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
    
    init(network: Network<ChatAPI>) {
        self.network = network
    }
    
    func fetchJoinedChatList() -> Single<NetworkResultWithArray<Room>> {
        
        return network.requestArray(.getRoom, type: Room.self)
            .map { result in
                switch result {
                case .success(let rooms):
                    return .success(rooms)
                case .error(let error):
                    return .error(error)
                }
            }
    }
}
