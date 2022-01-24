//
//  UploadNewPostReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/22.
//

import Foundation
import ReactorKit
import RxSwift


final class UploadNewPostReactor: Reactor {
    
    let initialState: State
    let postService: PostServiceType
    let mediaService: MediaServiceType
    
    enum Action {
        case updateTitle(String)
        case updatePrice(String)
        case updateShippingFee(String)
        case updateGatheringPeople(String)

//        case updatePerPersonPrice(String, String, String)
        case updateReferenceUrl(String)
//        case updatePostDetail(String)
        
    }
    
    enum Mutation {
        case setTitle(String)
        case setPrice(String)
        case setShippingFee(String)
        case setGatheringPeople(String)
        case setReferenceUrl(String)
    }
    
    struct State {
        
        var title: String?
        var price: String?
        var shippingFee: String?
        var totalGatheringPeople: String?
        var referenceUrl: String?
        var postDetail: String?
        
        
        var isLoading: Bool = false
        
    }
    
    init(postService: PostServiceType, mediaService: MediaServiceType) {
        self.postService = postService
        self.mediaService = mediaService
        
        self.initialState = State()
    }
    
    init(postService: PostServiceType, mediaService: MediaServiceType, editModel: EditPostModel) {
        self.postService = postService
        self.mediaService = mediaService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateTitle(let title):
            return Observable.just(Mutation.setTitle(title))
            
        case .updatePrice(let price):
            return Observable.just(Mutation.setPrice(price))
            
        case .updateShippingFee(let shippingFee):
            return Observable.just(Mutation.setShippingFee(shippingFee))
            
        case .updateGatheringPeople(let gatheringPeople):
            return Observable.just(Mutation.setGatheringPeople(gatheringPeople))
            
        case .updateReferenceUrl(let referenceUrl):
            return Observable.just(Mutation.setReferenceUrl(referenceUrl))
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setTitle(let title):
            state.title = title
            
        case .setPrice(let price):
            state.price = price.replacingOccurrences(of: ",", with: "")
            
        case .setShippingFee(let shippingFee):
            state.shippingFee = shippingFee.replacingOccurrences(of: ",", with: "")
            
        case .setGatheringPeople(let gatheringPeople):
            state.totalGatheringPeople = gatheringPeople
            
        case .setReferenceUrl(let referenceUrl):
            state.referenceUrl = referenceUrl
        }
        return state
    }
    
}
