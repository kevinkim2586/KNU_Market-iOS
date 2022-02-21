//
//  UploadNewPostReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/22.
//

import UIKit
import ReactorKit
import RxSwift
import RxRelay
import RxFlow

final class UploadPostReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
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
        case downloadPreviousImageData         // 글 수정할 때만 실행 -> 이미지 비동기적으로 다운
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
        case setEditPostModel(EditPostModel)
        case setPreviousImages([UIImage])
        case empty
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


            return Observable.concat([
                Observable.just(Mutation.setIsLoading(true)),
                uploadActionType,
                Observable.just(Mutation.setIsLoading(false))
            ])
            
        case .uploadPost:
            
            let uploadActionType: Observable<Mutation> = determineUploadAction() == .uploadNewPost
            ? uploadPost()
            : updatePost()
            
            return uploadActionType
            
        case .configurePageWithEditModel:
            
            return Observable.just(Mutation.setEditPostModel(self.currentState.editPostModel!))
            
        case .downloadPreviousImageData:
            
            return Observable<Mutation>.create { observer in
                
                var images: [UIImage] = []
                
                if let imageFiles = self.currentState.editPostModel?.imageFiles {
                    
                    for file in imageFiles {
                        let imageUrl = URL(string: file.location ?? "")!
                        if let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                            images.append(image)
                        }
                    }
                    observer.onNext(Mutation.setPreviousImages(images))
                    observer.onCompleted()
                }
                return Disposables.create()
            }
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
            
        case .setEditPostModel(let model):
            
            state.title = model.title
            state.price = "\(model.price)"
            state.shippingFee = "\(model.shippingFee)"
            state.totalGatheringPeople = "\(model.headCount)"
            state.referenceUrl = model.referenceUrl
            state.postDetail = model.content
            
        case .setPreviousImages(let images):
            state.images = images
            
        case .empty: break
        }
        return state
    }
}

//MARK: - Methods

extension UploadPostReactor {
    
    private func determineUploadAction() -> UploadActionType {
        return self.currentState.editPostModel != nil ? .updateExistingPost : .uploadNewPost
    }
    
    private func uploadPost() -> Observable<Mutation> {
        
        let images: [Data] = AssetConverter.convertUIImagesToDataType(images: currentState.images)
        
        guard let uploadPostDTO = UploadPostRequestDTO.configureDTO(
            title: currentState.title,
            price: currentState.price,
            shippingFee: currentState.shippingFee,
            totalGatheringPeople: currentState.totalGatheringPeople,
            detail: currentState.postDetail,
            referenceUrl: currentState.referenceUrl,
            imageDatas: images
     
        ) else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }
        
        return self.postService.uploadNewPost(with: uploadPostDTO)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.didUpdatePost.post()
                    self.steps.accept(AppStep.uploadPostIsCompleted)
                    return .empty
        
                case .error(_):
                    return .setErrorMessage(ErrorMessage.uploadErrorMessage)
                }
            }
    }
    
    private func updatePost() -> Observable<Mutation> {
        
        let images: [Data] = AssetConverter.convertUIImagesToDataType(images: currentState.images)
        
        guard let uploadPostDTO = UploadPostRequestDTO.configureDTO(
            title: currentState.title,
            price: currentState.price,
            shippingFee: currentState.shippingFee,
            totalGatheringPeople: currentState.totalGatheringPeople,
            detail: currentState.postDetail,
            referenceUrl: currentState.referenceUrl,
            imageDatas: images
     
        ) else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }

        
        guard let pageUid = currentState.editPostModel?.pageUID else {
            return .just(Mutation.setErrorMessage(ErrorMessage.uploadErrorMessage))
        }
        
        return self.postService.updatePost(uid: pageUid, with: uploadPostDTO)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.didUpdatePost.post()
                    self.steps.accept(AppStep.uploadPostIsCompleted)
                    return .empty
                case .error(_):
                    return .setErrorMessage(ErrorMessage.uploadErrorMessage)
                }
            }
    }
}
