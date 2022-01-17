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

        
        case refreshPage
        
        case deletePost
        case editPost
        case markPostDone
        case updatePostAsRegathering
        case joinChat
        
        case blockUser

    }
    
    enum Mutation {
        
        case setPostDetails(PostDetailModel)
        
        case setAlertMessage(String, AlertMessageType)
        

        
        
        
        case setDidFailFetchingPost(Bool, String)
        case setDidDeletePost(Bool, String)
        case setDidMarkPostDone(Bool, String)
        case setDidEnterChat(Bool, Bool)        // DidEnterChat, isFirstEntranceToChat
        case setPostAsGatherComplete(Bool)
        
 

        
        case setIsFetchingData(Bool)
        case setAttemptingToEnterChat(Bool)
        
        case empty
    }
    
    struct State {
        
        let pageId: String
        let isFromChatVC: Bool      // ChatVC에서 넘어온거면 PostVC에서 "채팅방 입장" 버튼 눌렀을 때 입장이 아닌 그냥 뒤로가기가 되어야 하기 때문
        var nickname: String = ""
        var userJoinedChatRoomPIDS: [String] = []
        var userBannedPostUploaders: [String] = []
        
        var postModel: PostDetailModel?
        
        var inputSources: [InputSource] = []
   
    

        var alertMessage: String?
        var alertMessageType: AlertMessageType?
        

        
        var isFetchingData: Bool = false
        
        
        
        // Computed Properties
        
        var title: String {
            return postModel?.title ?? "로딩 중.."
        }
        
        var detail: String {
            return postModel?.postDetail ?? ""
        }

        var currentlyGatheredPeople: Int {
            guard let postModel = postModel else { return 1 }
            if postModel.currentlyGatheredPeople < 1 { return 1 }
            return postModel.currentlyGatheredPeople
        }
        
        var totalGatheringPeople: Int {
            return postModel?.totalGatheringPeople ?? 2
        }
        
        var location: String {
            let index = (postModel?.location ?? Location.listForCell.count - 1)
            guard index != Location.listForCell.count + 1 else {
                return Location.listForCell[Location.listForCell.count - 1]
            }
            return Location.listForCell[index - 1]
        }
        
        var date: String {
            return DateConverter.convertDateToIncludeTodayAndYesterday(postModel?.date ?? "")
        }
        
        var viewCount: String {
            guard let postModel = postModel else { return "조회 -" }
            return "조회 \(postModel.viewCount)"
        }
        
        // 이미 참여하고 있는 공구인지
        var userAlreadyJoinedPost: Bool {
            return userJoinedChatRoomPIDS.contains(pageId) ? true : false
        }
        
        // 사용자가 올린 공구인지 여부
        var postIsUserUploaded: Bool {
            return postModel?.nickname == nickname
        }
        
        // 인원이 다 찼는지 여부
        var isFull: Bool {
            return postModel?.isFull ?? true
        }
        
        // 공구 마감 여부
        var isCompletelyDone: Bool {
            return postModel?.isCompletelyDone ?? true
        }
        
        // 모집 여부
        var isGathering: Bool {
            return isCompletelyDone ? false : true
        }
        
        // 채팅방 입장 버튼 활성화 여부
        var shouldEnableChatEntrance: Bool {
            return postIsUserUploaded || isGathering || userAlreadyJoinedPost
        }
        
        
        
        
        // 상태
        var didDeletePost: Bool = false
        var didMarkPostDone: Bool = false
        
        
    
        
        
        var didUpdatePostGatheringStatus: Bool = false
        var didFailFetchingPost: Bool = false
        var didEnterChat: Bool = false
        var isFirstEntranceToChat: Bool = false
        var isAttemptingToEnterChat: Bool = false
        
        
        
        

        
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
            isFromChatVC: isFromChatVC
        )
        
        self.initialState.nickname = userDefaultsService.get(key: UserDefaults.Keys.nickname) ?? ""
        self.initialState.userJoinedChatRoomPIDS = userDefaultsService.get(key: UserDefaults.Keys.joinedChatRoomPIDs) ?? []
        self.initialState.userBannedPostUploaders = userDefaultsService.get(key: UserDefaults.Keys.bannedPostUploaders) ?? []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .viewDidLoad:
            
            return Observable.concat([
                
                Observable.just(Mutation.setIsFetchingData(true)),
                fetchPostDetails(),
                fetchEnteredRoomInfo(),
                Observable.just(Mutation.setIsFetchingData(false))
            ])
            
        case .refreshPage:
        
            return Observable.concat([
                Observable.just(Mutation.setIsFetchingData(true)),
                fetchPostDetails(),
                Observable.just(Mutation.setIsFetchingData(false))
            ])
            
        case .deletePost:
            return .empty()
//            return deletePost()
            
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
            
            return .empty()
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
            
        case .setDidEnterChat(let didEnterChat, let isFirstEntranceToChat):
            state.didEnterChat = didEnterChat
            state.isFirstEntranceToChat = isFirstEntranceToChat
            
        case .setAttemptingToEnterChat(let isAttempting):
            state.isAttemptingToEnterChat = isAttempting
            
        case .setAlertMessage(let alertMessage, let alertMessageType):
            state.alertMessage = alertMessage
            state.alertMessageType = alertMessageType
            
        case .setPostAsGatherComplete(let gatherComplete):
    
            break
        
            
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
    
    private func updatePostAsRegathering() -> Observable<Mutation> {
        
        let model = UpdatePostRequestDTO(
            title: currentState.title,
            location: currentState.postModel?.location ?? 0,
            detail: currentState.detail,
            imageUIDs: currentState.postModel?.imageUIDs ?? [],
            totalGatheringPeople: currentState.totalGatheringPeople,
            currentlyGatheredPeople: currentState.currentlyGatheredPeople,
            isCompletelyDone: false
        )
        
        return postService.updatePost(uid: currentState.pageId, with: model)
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    NotificationCenterService.updatePostList.post()
                    return Mutation.setPostAsGatherComplete(true)
                    
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
//
//    private func blockPostUploader() -> Observable<Mutation> {
//
//    }
}

//MARK: - Conversion Methods
//
//extension PostViewReactor {
//
//    private func convertImageUIDsToInputSources(imageUIDs: [String]) -> [InputSource] {
//
//        let imageURLs = imageUIDs.compactMap {
//            URL(string: K.MEDIA_REQUEST_URL + $0)
//        }
//
//        var imageSources: [InputSource] = []
//
//        imageURLs.forEach { imageURL in
//            imageSources.append(SDWebImageSource(
//                url: imageURL,
//                placeholder: UIImage(named: K.Images.defaultItemImage))
//            )
//        }
//        return imageSources
//    }
//}
