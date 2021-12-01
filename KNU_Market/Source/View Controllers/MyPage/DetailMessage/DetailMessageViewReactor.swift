//
//  DetailMessageViewReactor.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//


import Foundation

import ReactorKit
import RxRelay

final class DetailMessageViewReactor: Reactor {
    
    let initialState: State
    
    enum Action {
        case appear
    }
    
    enum Mutation {
        case empty
    }
    
    struct State {
        var title: String
        var content: String
        var answer: String
        var uid: Int
    }
    
    fileprivate let myPageService: MyPageServiceType
    init(title: String, content: String, answer: String?, uid: Int, myPageService: MyPageServiceType) {
        self.initialState = State(title: title, content: content, answer: answer ?? "", uid: uid)
        
        self.myPageService = myPageService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .appear:
            return self.myPageService.viewMessage(self.currentState.uid).asObservable()
                .map { result in
                switch result {
                case .success:
                    print("success")
                case let .error(error):
                    print(error)
                }
                
                return .empty
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        let state = state
        
        switch mutation {
        case .empty:
            break
        }
        
        return state
    }
}

