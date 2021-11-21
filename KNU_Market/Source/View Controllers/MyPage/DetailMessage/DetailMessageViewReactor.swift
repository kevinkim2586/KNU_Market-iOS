//
//  DetailMessageViewReactor.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//


import Foundation

import ReactorKit
import RxRelay

final class DetailMessageViewReactor: Reactor, Stepper {
    
    let initialState: State
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

