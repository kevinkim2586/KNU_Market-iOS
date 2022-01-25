//
//  UploadNewPostReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/22.
//

import UIKit
import ReactorKit
import RxSwift


final class UploadNewPostReactor: Reactor {
    
    let initialState: State
    let postService: PostServiceType
    let mediaService: MediaServiceType
    
    enum Action {
        case updateImages([UIImage])
        case deleteImages(Int)
        case updateTitle(String)
        case updatePrice(String)
        case updateShippingFee(String)
        case updateGatheringPeople(String)
        case updateReferenceUrl(String)
        case updatePostDetail(String)
        case uploadPost
    }
    
    enum Mutation {
        case setImages([UIImage])
        case deleteImages(Int)
        case setTitle(String)
        case setPrice(String)
        case setShippingFee(String)
        case setGatheringPeople(String)
        case setReferenceUrl(String)
        case setDetail(String)
        case setIsLoading(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var images: [UIImage] = []
        var title: String?
        var price: String?
        var shippingFee: String?
        var totalGatheringPeople: String?
        var referenceUrl: String?
        var postDetail: String?
        
        
        var isLoading: Bool = false
        var errorMessage: String?
        
        var didCompleteUpload: Bool = false
        var didUpdatePost: Bool = false
        
        
    }
    
    init(
        postService: PostServiceType,
        mediaService: MediaServiceType
    ) {
        self.postService = postService
        self.mediaService = mediaService
        
        self.initialState = State()
    }
    
    init(
        postService: PostServiceType,
        mediaService: MediaServiceType,
        editModel: EditPostModel
    ) {
        self.postService = postService
        self.mediaService = mediaService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .updateImages(let images):
            return Observable.just(Mutation.setImages(images))
            
        case .deleteImages(let index):
            return Observable.just(Mutation.deleteImages(index))    //
            
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
            
        case .updatePostDetail(let postDetail):
            return Observable.just(Mutation.setDetail(postDetail))
            
        case .uploadPost:
            
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                
                Observable.just(Mutation.setIsLoading(false))
            ])
            
 
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {
            
        case .setImages(let images):
            state.images = images
      
            
        case .deleteImages(let index):
            state.images.remove(at: index)

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
            
        case .setDetail(let postDetail):
            state.postDetail = postDetail
            
        case .setIsLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
    
}

//MARK: - API Methods

extension UploadNewPostReactor {
    
//    private func uploadPost() -> Observable<Mutation> {
//
//    }
}
