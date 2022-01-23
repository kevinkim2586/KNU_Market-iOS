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
//        case updateTitle(String)
//        case updatePrice(String)
//        case updateGatheringPeople(String)
//        case updateShippingFee(String)
//        case updatePerPersonPrice(String, String, String)
//        case updateReferenceUrl(String)
//        case updatePostDetail(String)
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
        
        var title: String
        var price: Int
        var totalGatheringPeople: Int
        var shippingFee: Int
        var referenceUrl: String
        var postDetail: String
        
        
        var isLoading: Bool = false
        
    }
    
    init(postService: PostServiceType, mediaService: MediaServiceType) {
        self.postService = postService
        self.mediaService = mediaService
        
        self.initialState = State(
            title: "",
            price: 0,
            totalGatheringPeople: 2,
            shippingFee: 0,
            referenceUrl: "",
            postDetail: ""
        )
    }
    
    init(postService: PostServiceType, mediaService: MediaServiceType, editModel: EditPostModel) {
        self.postService = postService
        self.mediaService = mediaService
        self.initialState = State(
            title: "",
            price: 0,
            totalGatheringPeople: 2,
            shippingFee: 0,
            referenceUrl: "",
            postDetail: ""
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
    
}
