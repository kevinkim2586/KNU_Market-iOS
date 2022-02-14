//
//  ChatMemberListReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/09.
//

import Foundation
import RxSwift
import RxRelay
import RxFlow
import ReactorKit

final class ChatMemberListReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let chatService: ChatServiceAPIType
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        let roomInfo: RoomInfo
        let postUploaderUid: String
    }
    
    init(chatService: ChatServiceAPIType, roomInfo: RoomInfo, postUploaderUid: String) {
        self.chatService = chatService
        
        self.initialState = State(roomInfo: roomInfo, postUploaderUid: postUploaderUid)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
