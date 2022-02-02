//
//  UploadNewPostReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/22.
//

import UIKit
import ReactorKit
import RxSwift


final class UploadPostReactor: Reactor {
    
    let initialState: State
    let postService: PostServiceType
    let mediaService: MediaServiceType
    
    private struct ErrorMessage {
        static let uploadErrorMessage: String = "글 업로드에 문제가 발생했어요! 다시 시도해 주세요."
    }
    
    private enum UploadActionType {
        case uploadNewPost
        case updateExistingPost
    }
    
    enum Action {
        case updateImages([UIImage])
        case deleteImages(Int)
        case updateTitle(String)
        case updatePrice(String)
        case updateShippingFee(String)
        case updateGatheringPeople(String)
        case updateReferenceUrl(String)
        case updatePostDetail(String)
        case pressedUploadPost
        case uploadPost
        case configurePageWithEditModel
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
        case appendImageUid(String)
        case setCompleteUploadingPost(Bool)
        case setEditPostModel(EditPostModel)
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
        
        var imageUids: [String] = []
        var isCompletedImageUpload: Bool = false
        var editPostModel: EditPostModel?
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
        self.initialState = State(editPostModel: editModel)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .updateImages(let images):
            return Observable.just(Mutation.setImages(images))
            
        case .deleteImages(let index):
            return Observable.just(Mutation.deleteImages(index))
            
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
            
        case .pressedUploadPost:
        
            // 공구글 신규 업로드인지, 기존 글 수정인지에 따라 수행할 함수 변경
            let uploadActionType: Observable<Mutation> = determineUploadAction() == .uploadNewPost
            ? uploadPost()
            : updatePost()

            // 이미지를 업로드 할 필요가 있으면 업로드
            let uploadFunction: Observable<Mutation> = determineIfImageUploadIsNeeded() == true
            ? uploadImagesFirst()
            : uploadActionType
            
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                uploadFunction,
                Observable.just(Mutation.setIsLoading(false))
            ])
            
        case .uploadPost:
            
            let uploadActionType: Observable<Mutation> = determineUploadAction() == .uploadNewPost
            ? uploadPost()
            : updatePost()
            
            return uploadActionType
            
        case .configurePageWithEditModel:
            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                Observable.just(Mutation.setEditPostModel(self.currentState.editPostModel!)),
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
            
        case .appendImageUid(let imageUid):
            state.imageUids.append(imageUid)
            
            if state.images.count == state.imageUids.count {
                state.isCompletedImageUpload = true
            }
            
        case .setCompleteUploadingPost(let didComplete):
            state.didCompleteUpload = didComplete
            
        case .setEditPostModel(let model):
            
            state.title = model.title
            state.price = "\(model.price)"
            state.shippingFee = "\(model.shippingFee)"
            state.totalGatheringPeople = "\(model.totalGatheringPeople)"
            state.referenceUrl = model.referenceUrl
            state.postDetail = model.postDetail

            if let imageUids = model.imageUIDs {
                for imageUid in imageUids {
                    let url = URL(string: K.MEDIA_REQUEST_URL + imageUid)!
                    if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                        state.images.append(image)
                    }
                }
            }
        }
        
        return state
    }
}

//MARK: - Methods

extension UploadPostReactor {
    
    private func determineUploadAction() -> UploadActionType {
        return self.currentState.editPostModel != nil ? .updateExistingPost : .uploadNewPost
    }
    
    private func determineIfImageUploadIsNeeded() -> Bool {
        return self.currentState.images.isEmpty ? false : true
    }
    
    private func uploadImagesFirst() -> Observable<Mutation> {
        
        let imageDatas: [Data] = self.currentState.images.map { $0.jpegData(compressionQuality: 1.0) ?? Data() }
        
        return Observable.from(imageDatas)
            .concatMap { imageData -> Observable<Mutation> in
                
                return self.mediaService.uploadImage(with: imageData)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let imageModel):
                            return .appendImageUid(imageModel.uid)
                        case .error(_):
                            return .setErrorMessage(ErrorMessage.uploadErrorMessage)
                        }
                    }
            }
    }
    
    private func uploadPost() -> Observable<Mutation> {
        
        guard let uploadPostDTO = UploadPostRequestDTO.configureDTO(
            title: currentState.title,
            price: currentState.price,
            shippingFee: currentState.shippingFee,
            totalGatheringPeople: currentState.totalGatheringPeople,
            detail: currentState.postDetail,
            referenceUrl: currentState.referenceUrl,
            imageUIDs: currentState.imageUids
        ) else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }
        
        return self.postService.uploadNewPost(with: uploadPostDTO)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    return .setCompleteUploadingPost(true)
                case .error(_):
                    return .setErrorMessage(ErrorMessage.uploadErrorMessage)
                }
            }
    }
    
    private func updatePost() -> Observable<Mutation> {
        
        guard let updatePostDTO = UpdatePostRequestDTO.configureDTO(
            title: currentState.title,
            detail: currentState.postDetail,
            imageUids: currentState.imageUids,
            totalGatheringPeople: currentState.totalGatheringPeople,
            currentlyGatheredPeople: currentState.editPostModel?.currentlyGatheredPeople,
            referenceUrl: currentState.referenceUrl,
            shippingFee: currentState.shippingFee,
            price: currentState.price
        ) else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }
        
        guard let pageUid = currentState.editPostModel?.pageUID else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }
        
        return self.postService.updatePost(uid: pageUid, with: updatePostDTO)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.didUpdatePost.post()
                    return .setCompleteUploadingPost(true)
                case .error(_):
                    return .setErrorMessage(ErrorMessage.uploadErrorMessage)
                }
            }
    }
}
