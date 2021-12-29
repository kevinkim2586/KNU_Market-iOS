//
//  MyPostsViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift
import ReactorKit

final class MyPostsViewReactor: Reactor {
    
    let initialState: State
    let postService: PostService
//    let chatService: ChatService
    
    enum Action {
        
    }
    
    enum Mutation {
        
        
    }
    
    struct State {
        
        var errorMessage: String?
    }
    
    init(postService: PostService) {
        self.postService = postService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
    
    
}
