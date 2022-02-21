//
//  PostViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/08.
//

import UIKit
import ImageSlideshow
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

enum AlertMessageType {
    case appleDefault
    case simpleBottom
    case custom
}

final class PostViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    var initialState: State
    let postService: PostServiceType
    let chatService: ChatServiceAPIType
    let sharingService: SharingServiceType
    let userDefaultsService: UserDefaultsGenericServiceType
    
    enum Action {
        case viewDidLoad
        case popVC
        case refresh
        case deletePost
        case editPost
        case markPostDone               // 방장 - 모집 완료
        case updatePostAsRegathering    // 방장 - 모집 완료 해제
        case joinChat
        case blockUser
        case sharePost
        case showPerPersonPrice(preferredContentSize: CGSize, sourceView: UIView, delegateController: PostViewController)
        case reportPostUploader
    }
    
    enum Mutation {
        case setPostDetails(PostDetailModel)
        case setAlertMessage(String, AlertMessageType)
        case setDidFailFetchingPost(Bool, String)
        case setDidMarkPostDone(alertMessage: String)
        case setIsFetchingData(Bool)
        case setAttemptingToEnterChat(Bool)
        case setIsLoading(Bool)
        case empty
    }
    
    struct State {
        
        let pageId: String
        let isFromChatVC: Bool      // ChatVC에서 넘어온거면 PostVC에서 "채팅방 입장" 버튼 눌렀을 때 입장이 아닌 그냥 뒤로가기가 되어야 하기 때문
        var myNickname: String = ""
        var userJoinedChatRoomPIDS: [String] = []
        
        var postModel: PostDetailModel
        var inputSources: [InputSource] = []
        var alertMessage: String?
        var alertMessageType: AlertMessageType?
        var isFetchingData: Bool = false
        
        // Computed Properties
        
        var postUploaderNickname: String {
            return postModel.createdBy.displayName ?? ""
        }
        
        var title: String {
            return postModel.title
        }
        
        var priceForEachPerson: String? {
            
            if let price = postModel.price, let shippingFee = postModel.shippingFee {
                let perPersonPrice = (price + shippingFee) / postModel.totalGatheringPeople
                return perPersonPrice.withDecimalSeparator
            } else {
                return nil
            }
        }
        
        var priceForEachPersonInInt: Int {
            if let price = postModel.price, let shippingFee = postModel.shippingFee {
                return (price + shippingFee) / postModel.totalGatheringPeople
            } else {
                return 0
            }
        }
        
        var productPrice: Int {
            return postModel.price ?? 0
        }
        
        var shippingFee: Int {
            return postModel.shippingFee ?? 0
        }
        
        var detail: String {
            return postModel.postDetail
        }
        
        var currentlyGatheredPeople: Int {
            if postModel.currentlyGatheredPeople < 1 { return 1 }
            return postModel.currentlyGatheredPeople
        }
        
        var totalGatheringPeople: Int {
            return postModel.totalGatheringPeople
        }
        
        var date: String {
            return DateConverter.convertDateStringToSimpleFormat(postModel.createdAt)
        }
        
        var viewCount: String {
            return "조회 \(postModel.viewCount)"
        }
        
        // 이미 참여하고 있는 공구인지
        var userAlreadyJoinedPost: Bool {
            return userJoinedChatRoomPIDS.contains(pageId) ? true : false
        }
        
        // 사용자가 올린 공구인지 여부
        var postIsUserUploaded: Bool {
            return postModel.createdBy.displayName == myNickname
        }
        
//        // 인원이 다 찼는지 여부 -> recruitedAt날짜가 있으면 모집 완료 API를 때린 적이 있다는 것
//        var isFull: Bool {
//            return postModel.recruitedAt == nil ? false : true
//        }
        
        // 공구 마감 여부
        var isCompletelyDone: Bool {
            return postModel.isRecruited == 0 ? false : true
        }
        
        // 모집 여부
        var isGathering: Bool {
            return isCompletelyDone ? false : true
        }
        
        // 채팅방 입장 버튼 활성화 여부
        var shouldEnableChatEntrance: Bool {
            return postIsUserUploaded || isGathering || userAlreadyJoinedPost
        }
        
        var referenceUrl: URL? {
            if let referenceUrl = postModel.referenceUrl, let encodedString = referenceUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                return URL(string: encodedString)
            } else { return nil }
        }
        
        var editModel: EditPostModel?
        
        // 상태
        var didFailFetchingPost: Bool = false           // 글 불러오기 실패

        var isAttemptingToEnterChat: Bool = false       // 채팅방 입장 시도 중
        var isLoading: Bool = false
    }
    
    //MARK: - Initialization
    
    init(
        pageId: String,
        isFromChatVC: Bool = false,
        postService: PostServiceType,
        chatService: ChatServiceAPIType,
        sharingService: SharingServiceType,
        userDefaultsService: UserDefaultsGenericServiceType
    ) {
        self.postService = postService
        self.chatService = chatService
        self.sharingService = sharingService
        self.userDefaultsService = userDefaultsService
        self.initialState = State(
            pageId: pageId,
            isFromChatVC: isFromChatVC,
            postModel: PostDetailModel.getDefaultState()
        )
        
        self.initialState.myNickname = userDefaultsService.get(key: UserDefaults.Keys.displayName) ?? ""
        self.initialState.userJoinedChatRoomPIDS = userDefaultsService.get(key: UserDefaults.Keys.joinedChatRoomPIDs) ?? []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .viewDidLoad:
            return Observable.concat([
                fetchPostDetails(),
                fetchEnteredRoomInfo(),
            ])
            
        case .popVC:
            self.steps.accept(AppStep.popViewController)
            return .empty()
            
        case .refresh:
            return fetchPostDetails()
            
        case .deletePost:
            return deletePost()
            
        case .markPostDone:
            return markPostDone()
            
        case .updatePostAsRegathering:
            return updatePostAsRegathering()
            
        case .joinChat:
            return Observable.concat([
                Observable.just(Mutation.setAttemptingToEnterChat(true)),
                joinChat(),
                Observable.just(Mutation.setAttemptingToEnterChat(false))
            ])
            
        case .blockUser:
            blockPostUploader()
            self.steps.accept(AppStep.popViewController)
            return .empty()
            
        case .editPost:
            return configureEditPostModel()
            
        case .sharePost:
            self.sharingService.sharePost(
                postUid: currentState.postModel.uuid,
                titleMessage: currentState.postModel.title,
                imageFilePaths: currentState.postModel.postFile?.files
            )
            return .empty()
            
        case let .showPerPersonPrice(preferredContentSize, sourceView, delegateController):
            
            let perPersonPriceModel = PerPersonPriceModel(
                productPrice: currentState.productPrice,
                shippingFee: currentState.shippingFee,
                totalPrice: currentState.productPrice + currentState.shippingFee,
                totalGatheringPeople: currentState.totalGatheringPeople,
                perPersonPrice: currentState.priceForEachPersonInInt
            )
            
            self.steps.accept(AppStep.perPersonPricePopupIsRequired(
                model: perPersonPriceModel,
                preferredContentSize: preferredContentSize,
                sourceView: sourceView,
                delegateController: delegateController)
            )
            
            return .empty()
            
        case .reportPostUploader:
            
            self.steps.accept(AppStep.reportIsRequired(
                userToReport: currentState.postModel.createdBy.displayName ?? "",
                postUid: currentState.pageId)
            )
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        state.alertMessage = nil
        state.alertMessageType = nil
        
        switch mutation {
        case .setPostDetails(let postDetailModel):
            state.postModel = postDetailModel
            
            if let imagePaths = postDetailModel.postFile?.files {
                state.inputSources = AssetConverter.convertImagePathsToInputSources(imagePaths: imagePaths)
            }
            
        case .setDidFailFetchingPost(let didFail, let alertMessage):
            state.didFailFetchingPost = didFail
            state.alertMessage = alertMessage
            
        case .setDidMarkPostDone(let alertMessage):
            state.alertMessage = alertMessage
            state.alertMessageType = .simpleBottom
            
        case .setAttemptingToEnterChat(let isAttempting):
            state.isAttemptingToEnterChat = isAttempting
            
        case .setAlertMessage(let alertMessage, let alertMessageType):
            state.alertMessage = alertMessage
            state.alertMessageType = alertMessageType
            
        case .setIsFetchingData(let isFetching):
            state.isFetchingData = isFetching
            
        case .setIsLoading(let isLoading):
            state.isLoading = isLoading
            
        case .empty:
            break
        }
        return state
    }
}

//MARK: - API Methods

extension PostViewReactor {
    
    private func fetchPostDetails() -> Observable<Mutation> {
        
        guard currentState.isFetchingData == false else { return .empty() }
        
        return postService.fetchPostDetails(uid: currentState.pageId)
            .asObservable()
            .map { result in
                switch result {
                case .success(let postDetailModel):
                    return Mutation.setPostDetails(postDetailModel)
                    
                case .error(_):
                    return Mutation.setAlertMessage("존재하지 않는 글입니다.🧐", .appleDefault)
                }
            }
    }
    
    private func deletePost() -> Observable<Mutation> {
        
        return postService.deletePost(uid: currentState.pageId)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.updatePostList.post()
                    self.steps.accept(AppStep.popViewController)
                    return .empty

                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription, .simpleBottom)
                }
            }
    }
    
    private func markPostDone() -> Observable<Mutation> {
        
        return postService.markPostDone(uid: currentState.pageId)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.updatePostList.post()
                    return Mutation.setDidMarkPostDone(alertMessage: "모집 완료를 축하합니다.🎉")
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription, .simpleBottom)
                }
            }
    }
    
    private func configureEditPostModel() -> Observable<Mutation> {
        
        let editPostModel = EditPostModel(
            pageUID: currentState.postModel.uuid,
            title: currentState.postModel.title,
            content: currentState.postModel.postDetail,
            headCount: currentState.postModel.totalGatheringPeople,
            currentlyGatheredPeople: currentState.postModel.currentlyGatheredPeople,
            price: currentState.postModel.price ?? 0,
            shippingFee: currentState.postModel.shippingFee ?? 0,
            referenceUrl: currentState.postModel.referenceUrl,
            imageFiles: currentState.postModel.postFile?.files
        )
        

        self.steps.accept(AppStep.editPostIsRequired(editModel: editPostModel))
        return .empty()
    }
    
    private func updatePostAsRegathering() -> Observable<Mutation> {
      
//        let updateModel = UpdatePostRequestDTO.configureDTOForMarkingPostAsRegathering(
//            title: currentState.postModel.title,
//            detail: currentState.postModel.postDetail,
//            imageUIDs: currentState.postModel.imageUIDs,
//            totalGatheringPeople: currentState.totalGatheringPeople,
//            currentlyGatheredPeople: currentState.currentlyGatheredPeople,
//            referenceUrl: currentState.postModel.referenceUrl,
//            shippingFee: currentState.postModel.shippingFee,
//            price: currentState.postModel.price
//        )
//
//        return postService.updatePost(uid: currentState.postModel.uuid, with: updateModel)
//            .asObservable()
//            .map { result in
//                switch result {
//                case .success:
//                    NotificationCenterService.updatePostList.post()
//                    return Mutation.empty
//                case .error(let error):
//                    return Mutation.setAlertMessage(error.errorDescription, .simpleBottom)
//                }
//            }
        return .empty()
    }
    
    private func joinChat() -> Observable<Mutation> {
        
        if currentState.currentlyGatheredPeople ==
            currentState.totalGatheringPeople
            && !currentState.postIsUserUploaded
            && !currentState.userAlreadyJoinedPost {
            return .just(Mutation.setAlertMessage(NetworkError.E001.errorDescription, .custom))
        }
        
        return chatService.changeJoinStatus(chatFunction: .join, pid: currentState.pageId)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.updatePostList.post()
                    
                    self.steps.accept(AppStep.chatIsPicked(
                        roomUid: self.currentState.pageId,
                        chatRoomTitle: self.currentState.title,
                        postUploaderUid: self.currentState.postModel.createdBy.userId,
                        isFirstEntrance: true)
                    )
                    return .empty
                    
                case .error(let error):
                    NotificationCenterService.updatePostList.post()
                    switch error {
                    case .E108:     ///이미 참여하고 있는 채팅방이면 성공은 성공임. 그러나 기존의 메시지를 불러와야함
                     
                        self.steps.accept(AppStep.chatIsPicked(
                            roomUid: self.currentState.pageId,
                            chatRoomTitle: self.currentState.title,
                            postUploaderUid: self.currentState.postModel.createdBy.userId,
                            isFirstEntrance: false)
                        )
                        return .empty
                        
                    default:
                        return Mutation.setAlertMessage(error.errorDescription, .custom)
                    }
                }
            }
    }
    
    private func fetchEnteredRoomInfo() -> Observable<Mutation> {
        
        return chatService.fetchJoinedChatList()
            .asObservable()
            .map { _ in
                return Mutation.empty
            }
    }
    
    private func blockPostUploader() {
        
        let userToBlock = currentState.postModel.createdBy.userId
        var bannedUsers: [String] = userDefaultsService.get(key: UserDefaults.Keys.bannedPostUploaders) ?? []
        
        bannedUsers.append(userToBlock)
        
        userDefaultsService.set(
            key: UserDefaults.Keys.bannedPostUploaders,
            value: bannedUsers
        )
        NotificationCenterService.updatePostList.post()
    }
}

