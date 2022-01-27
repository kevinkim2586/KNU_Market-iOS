//
//  PostViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/08.
//

import Foundation
import ImageSlideshow
import RxSwift
import ReactorKit

enum AlertMessageType {
    case appleDefault
    case simpleBottom
    case custom
}

final class PostViewReactor: Reactor {
    
    var initialState: State
    let postService: PostServiceType
    let chatService: ChatServiceAPIType
    let userDefaultsService: UserDefaultsGenericServiceType
    
    enum Action {
        
        case viewDidLoad
        case refresh
        case deletePost
        case editPost
        case markPostDone               // 방장 - 모집 완료
        case updatePostAsRegathering    // 방장 - 모집 완료 해제
        case joinChat
        case blockUser(String)
    }
    
    enum Mutation {
        
        case setPostDetails(PostDetailModel)
        
        case setAlertMessage(String, AlertMessageType)
        
        case setDidFailFetchingPost(Bool, String)
        case setDidDeletePost(Bool, String)
        case setDidMarkPostDone(Bool, String)
        case setDidEnterChat(Bool, Bool)            // DidEnterChat, isFirstEntranceToChat
    
        
        case setEditPostModel(EditPostModel)
 
        case setIsFetchingData(Bool)
        case setAttemptingToEnterChat(Bool)
        case setDidBlockUser(Bool)
        
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
            return postModel.nickname
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
            return DateConverter.convertDateStringToSimpleFormat(postModel.date)
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
            return postModel.nickname == myNickname
        }
        
        // 인원이 다 찼는지 여부
        var isFull: Bool {
            return postModel.isFull
        }
        
        // 공구 마감 여부
        var isCompletelyDone: Bool {
            return postModel.isCompletelyDone
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
            if let referenceUrl = postModel.referenceUrl {
                return URL(string: referenceUrl)
            } else { return nil }
        }
        
        var editModel: EditPostModel?
        
        // 상태
        var didDeletePost: Bool = false                 // 글 삭제 상태
        var didMarkPostDone: Bool = false               // 글 모집 완료 상태
        var didBlockUser: Bool = false                  // 유저 차단 상태
        var didFailFetchingPost: Bool = false           // 글 불러오기 실패
        var didEnterChat: Bool = false                  // 채팅방 입장 성공 시
        var isFirstEntranceToChat: Bool = false         // 채팅방 입장이 처음인지, 아니면 기존에 입장한 채팅방인지에 대한 판별 상태
        var isAttemptingToEnterChat: Bool = false       // 채팅방 입장 시도 중
    }
    
    
    //MARK: - Initialization
    
    init(
        pageId: String,
        isFromChatVC: Bool = false,
        postService: PostServiceType,
        chatService: ChatServiceAPIType,
        userDefaultsService: UserDefaultsGenericServiceType
    ) {
        self.postService = postService
        self.chatService = chatService
        self.userDefaultsService = userDefaultsService
        self.initialState = State(
            pageId: pageId,
            isFromChatVC: isFromChatVC,
            postModel: PostDetailModel.getDefaultState()
        )
        
        self.initialState.myNickname = userDefaultsService.get(key: UserDefaults.Keys.nickname) ?? ""
        self.initialState.userJoinedChatRoomPIDS = userDefaultsService.get(key: UserDefaults.Keys.joinedChatRoomPIDs) ?? []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .viewDidLoad:
            return Observable.concat([
                fetchPostDetails(),
                fetchEnteredRoomInfo(),
            ])
            
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
            return .empty()

        case .editPost:
            return configureEditPostModel()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil
        state.alertMessageType = nil
        state.didEnterChat = false

        
        switch mutation {
            
        case .setPostDetails(let postDetailModel):
            state.postModel = postDetailModel
            if let postImageUIDs = postDetailModel.imageUIDs {
                state.inputSources = AssetConverter.convertImageUIDsToInputSources(imageUIDs: postImageUIDs)
            }
            
        case .setDidFailFetchingPost(let didFail, let alertMessage):
            state.didFailFetchingPost = didFail
            state.alertMessage = alertMessage
            
            
        case .setDidDeletePost(let didDelete, let alertMessage):
            state.didDeletePost = didDelete
            state.alertMessage = alertMessage
            
        case .setDidMarkPostDone(let didMarkPostDone, let alertMessage):
            state.didMarkPostDone = didMarkPostDone
            state.alertMessage = alertMessage
            state.alertMessageType = .simpleBottom
            
        case .setDidEnterChat(let didEnterChat, let isFirstEntranceToChat):
            state.didEnterChat = didEnterChat
            state.isFirstEntranceToChat = isFirstEntranceToChat
            
        case .setAttemptingToEnterChat(let isAttempting):
            state.isAttemptingToEnterChat = isAttempting
            
        case .setAlertMessage(let alertMessage, let alertMessageType):
            state.alertMessage = alertMessage
            state.alertMessageType = alertMessageType
            
        case .setEditPostModel(let editPostModel):
            state.editModel = editPostModel
            
        case .setDidBlockUser(let didBlock):
            state.didBlockUser = didBlock
        
        case .setIsFetchingData(let isFetching):
            state.isFetchingData = isFetching
        
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
                    return Mutation.setAlertMessage("존재하지 않는 글입니다 🧐", .appleDefault)
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
                    print("✅ delete POST SUCCESS")
                    return Mutation.setDidDeletePost(true, "게시글 삭제 완료 🎉")

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
                    return Mutation.setDidMarkPostDone(true, "모집 완료를 축하합니다.🎉")
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription, .simpleBottom)
                }
            }
    }
    
    private func configureEditPostModel() -> Observable<Mutation> {
        
        let editPostModel = EditPostModel(
            title: currentState.postModel.title,
            imageURLs: nil,
            imageUIDs: currentState.postModel.imageUIDs,
            totalGatheringPeople: currentState.postModel.totalGatheringPeople,
            currentlyGatheredPeople: currentState.currentlyGatheredPeople,
            location: Location.list.count,                        /// 당분간 8이 기본
            postDetail: currentState.postModel.postDetail,
            pageUID: currentState.postModel.uuid,
            price: currentState.postModel.price ?? 0,
            shippingFee: currentState.postModel.shippingFee ?? 0,
            referenceUrl: currentState.postModel.referenceUrl
        )
        
        return Observable.just(Mutation.setEditPostModel(editPostModel))
    }
    
    private func updatePostAsRegathering() -> Observable<Mutation> {

        
        let updateModel = UpdatePostRequestDTO(
            title: currentState.postModel.title,
            detail: currentState.postModel.postDetail,
            imageUIDs: currentState.postModel.imageUIDs,
            totalGatheringPeople: currentState.totalGatheringPeople,
            currentlyGatheredPeople: currentState.currentlyGatheredPeople,
            isCompletelyDone: false,                        // 모집 해제이니까 이 파라미터가 들어가야함
            referenceUrl: currentState.postModel.referenceUrl,
            shippingFee: currentState.postModel.shippingFee,
            price: currentState.postModel.price ?? 0
        )
        
        return postService.updatePost(uid: currentState.postModel.uuid, with: updateModel)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.updatePostList.post()
                    return Mutation.empty
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription, .simpleBottom)
                }
            }
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
                    return Mutation.setDidEnterChat(true, true)
                    
                case .error(let error):
                    NotificationCenterService.updatePostList.post()
                    switch error {
                    case .E108:     ///이미 참여하고 있는 채팅방이면 성공은 성공임. 그러나 기존의 메시지를 불러와야함
                        return Mutation.setDidEnterChat(true, false)
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

    private func blockPostUploader() -> Observable<Mutation> {
        
        let userToBlock = currentState.postModel.userUID
        var bannedUsers: [String] = userDefaultsService.get(key: UserDefaults.Keys.bannedPostUploaders) ?? []
        
        bannedUsers.append(userToBlock)
        
        userDefaultsService.set(
            key: UserDefaults.Keys.bannedPostUploaders,
            value: bannedUsers
        )
        NotificationCenterService.updatePostList.post()
        return Observable.just(Mutation.setDidBlockUser(true))
    }
}

