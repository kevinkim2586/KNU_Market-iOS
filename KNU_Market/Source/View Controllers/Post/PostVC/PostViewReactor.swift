//
//  PostViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/08.
//

import Foundation
import RxSwift
import ReactorKit

final class PostViewReactor: Reactor {
    
    let initialState: State
    let postService: PostServiceType
    let chatService: ChatServiceAPIType
    let userDefaultsService: UserDefaultsGenericServiceType
    
    enum Action {
        
        case viewDidLoad
        case updatePostControlButtonView
        case updatePostHeaderView
        case updatePostBottomView
        case refreshPage
        
        
        case deletePost
    }
    
    enum Mutation {
        
        case setPostDetails(PostDetailModel)
        
        case setAlertMessage(String)
        case setPopupAlertMessage(String)
        case empty
    }
    
    struct State {
        let pageId: String
        let isFromChatVC: Bool      // ChatVC에서 넘어온거면 PostVC에서 "채팅방 입장" 버튼 눌렀을 때 입장이 아닌 그냥 뒤로가기가 되어야 하기 때문
        
        var postModel: PostDetailModel?
    
        
        var alertMessage: String?
        var popupAlertMessage: String?
        var popVCAfterDelay: Bool = false
        
        
        
        // Computed Properties
        // nickname, joinedchatroom, bannedpostuploaders
  
        
        
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
        self.initialState = State(pageId: pageId, isFromChatVC: isFromChatVC)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
            
        case .viewDidLoad:
            
            return Observable.concat([
                fetchPostDetails(),
                fetchEnteredRoomInfo()
            ])
            
        case .updatePostControlButtonView:
            
            return Observable.empty()
            
        
        case .updatePostHeaderView:
            
            return Observable.empty()
            
        case .updatePostBottomView:
            
            return Observable.empty()
            
        case .refreshPage:
            return fetchPostDetails()
            
        case .deletePost:
            return Observable.empty()
//            return deletePost()
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil
        state.popupAlertMessage = nil
        
        
        
        
        
        return state
    }
}

//MARK: - API Methods

extension PostViewReactor {
    
    private func fetchPostDetails() -> Observable<Mutation> {

        return postService.fetchPostDetails(uid: currentState.pageId)
            .asObservable()
            .map { result in
                switch result {
                case .success(let postDetailModel):
                    return Mutation.setPostDetails(postDetailModel)
                    
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription)
                }
            }
    }

//    private func deletePost() -> Observable<Mutation> {

//        return postService.deletePost(uid: currentState.pageId)
//            .asObservable()
//            .map { result in
//                switch result {
//                case .success:
//
//
//
//                case .error(let error):
//                    return Mutation.setAlertMessage(error.errorDescription)
//                }
//            }
//    }
//
//    private func markPostDone() -> Observable<Mutation> {
//
//    }
//
//    private func updatePostAsRegathering() -> Observable<Mutation> {
//
//
//    }
//
//
//    private func joinPost() -> Observable<Mutation> {
//
//    }
//
    private func fetchEnteredRoomInfo() -> Observable<Mutation> {
        
        return chatService.fetchJoinedChatList()
            .asObservable()
            .map { _ in return Mutation.empty }
    }
//
//    private func blockPostUploader() -> Observable<Mutation> {
//
//    }
    
    
}
