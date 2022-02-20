//
//  BannerHeaderReacto.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/19.
//

import Foundation
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

final class BannerHeaderReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()

    let bannerService: BannerServiceType
    let initialState: State

    enum Action {
        case incrementBannerViewCount(bannerId: Int)
    }
    
    enum Mutation {
        case empty
    }
    
    struct State {
    }
    
    init() {
        self.bannerService = BannerService(network: Network<BannerAPI>(plugins: [AuthPlugin()]))
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .incrementBannerViewCount(let bannerId):
            
            return self.bannerService.incrementBannerViewCount(bannerId: bannerId)
                .asObservable()
                .map { result in
                    switch result {
                    case .success:
                        return .empty
                        
                    case .error(let error):
                        print("❗️ BannerHeaderReactor incrementBannerViewCount error: \(error)")
                        return .empty
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {

        case .empty:
            break
        }
        return state
    }
    
    
}
