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
        
    }
    
    typealias Mutation = NoMutation
    
    struct State {
        var title: String
        var content: String
        var answer: String
    }
    
    init(title: String, content: String, answer: String?) {
        self.initialState = State(title: title, content: content, answer: answer ?? "")
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
}

