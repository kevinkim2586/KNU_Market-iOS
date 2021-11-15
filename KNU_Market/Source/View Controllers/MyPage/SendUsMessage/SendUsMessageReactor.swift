//
//  SendUsMessageReactor.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/06.
//

import Foundation

import ReactorKit
import RxRelay
import UIKit

final class SendUsMessageReactor: Reactor {
    
    let initialState: State
    
    enum Action {
        case setImage([UIImage])
        case sendMessage
    }
    
    enum Mutation {
        case updateImage([UIImage])
        case setLoading(Bool)
    }
    
    struct State {
        var image: [UIImage] = []
        var title: String = ""
        var content: String = ""
        var isLoading: Bool = false
    }
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setImage(images):
            return Observable.just(Mutation.updateImage(images))
            
        case .sendMessage:
            return Observable.merge([
                Observable.just(Mutation.setLoading(true)),
                
                
                
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .updateImage(images):
            images.forEach {
                state.image.append($0)
            }
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        }
        
        return state
    }
}

