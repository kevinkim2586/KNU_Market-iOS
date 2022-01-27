//
//  BannerHeaderReacto.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/19.
//

import Foundation
import RxSwift
import ReactorKit

final class BannerHeaderReactor: Reactor {

    let bannerService: BannerServiceType
    let initialState: State

    
    enum Action {
        
        case setBannerModel([BannerModel])
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
        var bannerModel: [BannerModel] = []
    }
    
    init(bannerService: BannerServiceType) {
        self.bannerService = bannerService
        self.initialState = State()
    }
//    
//    func mutate(action: Action) -> Observable<Mutation> {
//        
//    }
//    
//    func reduce(state: State, mutation: Mutation) -> State {
//        var state = state
//        switch mutation {
//
//        }
//        return state
//    }
//    
    
}
