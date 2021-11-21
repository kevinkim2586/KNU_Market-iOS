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
import Moya

final class SendUsMessageReactor: Reactor {
    
    let initialState: State
    
    enum Action {
        case setImage([UIImage])
        case sendMessage
        case updateTitle(String)
        case updateContent(String)
        case deleteImage(Int)
    }
    
    enum Mutation {
        case updateImage([UIImage])
        case setLoading(Bool)
        case setTitle(String)
        case setContent(String)
        case deleteImage(Int)
    }
    
    struct State {
        var image: [UIImage] = []
        var title: String = ""
        var content: String = ""
        var isLoading: Bool = false
    }
    
    fileprivate let myPageService: MyPageServiceType
    init() {
        self.initialState = State()
        
        self.myPageService = MyPageService(network: Network<MyPageAPI>(plugins: [NetworkLoggerPlugin(), AuthPlugin()]))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setImage(images):
            return Observable.just(Mutation.updateImage(images))
            
        case let .updateTitle(title):
            return Observable.just(Mutation.setTitle(title))
            
        case let .updateContent(content):
            return Observable.just(Mutation.setContent(content))
            
        case let .deleteImage(idx):
            return Observable.just(Mutation.deleteImage(idx))
            
        case .sendMessage:
            var data: [Data] = []

            self.currentState.image.forEach {
                data.append($0.jpegData(compressionQuality: 0.6)!)
            }

            return Observable.merge([
                Observable.just(Mutation.setLoading(true)),

                self.myPageService.writeReport(self.currentState.title, self.currentState.content, data.first, data.last)
                    .map { result in
                        switch result {
                        case .success:
                            print("success")
                        case let .error(error):
                            print(error)
                        }
                    }.asObservable().flatMap { _ in Observable.empty() },

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
            
        case let .setTitle(title):
            state.title = title
            
        case let .setContent(content):
            state.content = content
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            
        case let .deleteImage(idx):
            state.image.remove(at: idx)
        }
        
        return state
    }
    
}
