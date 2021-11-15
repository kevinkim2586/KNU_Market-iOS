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
    }
    
    enum Mutation {
        case updateImage([UIImage])
    }
    
    struct State {
        var image: [UIImage] = []
    }
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setImage(images):
            return Observable.just(Mutation.updateImage(images))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .updateImage(images):
            images.forEach {
                state.image.append($0)
            }
        }
        
        return state
    }
}

