//
//  PostListViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/07.
//

import Foundation
import RxSwift
import ReactorKit

final class PostListViewReactor: Reactor {
    
    let initialState: State
    let postService: PostServiceType
    let chatListService: ChatListServiceType
    let userService: UserServiceType
    let popupService: PopupServiceType
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    let userNotificationService: UserNotificationServiceType
    
    enum Action {
        case loadInitialMethods
        case viewWillAppear
        case fetchPostList
        case refreshTableView
    }
    
    enum Mutation {
        case setPostList([PostListModel])
        case resetPostList([PostListModel])
        case incrementIndex
        case setUserNickname(String)
        case setNeedsToShowPopup(Bool, PopupModel?)
        case setErrorMessage(String)
        case setNeedsToFetchMoreData(Bool)
        case setIsFetchingData(Bool)
        case setIsRefreshingData(Bool)
        case empty
    }
    
    struct State {
        var postList: [PostListModel] = []
        var index: Int = 1
        var isFetchingData: Bool = false
        var isRefreshingData: Bool = false
        var needsToFetchMoreData: Bool = true
        var userNickname: String? = nil
        var errorMessage: String? = nil
        var needsToShowPopup: Bool = false
        var popupModel: PopupModel?
        var bannedPostUploaders: [String]         // 내가 차단한 유저
        var isUserVerified: Bool
        var isAllowedToUploadPost: Bool?
    }
    
    init(
        postService: PostServiceType,
        chatListService: ChatListServiceType,
        userService: UserServiceType,
        popupService: PopupServiceType,
        userDefaultsGenericService: UserDefaultsGenericServiceType,
        userNotificationService: UserNotificationServiceType
    ) {
        self.postService = postService
        self.chatListService = chatListService
        self.userService = userService
        self.popupService = popupService
        self.userDefaultsGenericService = userDefaultsGenericService
        self.userNotificationService = userNotificationService
        
        // 사용자가 개인적으로 차단한 유저 정보 불러오기
        let bannedPostUploaders: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.bannedPostUploaders) ?? []
        
        // 인증된 유저인지 아닌지 판별
        let isUserVerified: Bool = userDefaultsGenericService.get(key: UserDefaults.Keys.hasVerifiedEmail) ?? false
        
        self.initialState = State(
            bannedPostUploaders: bannedPostUploaders,
            isUserVerified: isUserVerified
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .loadInitialMethods:
            
            guard currentState.isFetchingData == false else { return Observable.empty() }
            
            return Observable.concat([
                
                Observable.just(Mutation.setIsFetchingData(true)),
                
                fetchEnteredRoomInfo(),
                loadUserProfile(),
                fetchPostList(at: currentState.index),
                fetchLatestPopup(),
                
                Observable.just(Mutation.incrementIndex),
                Observable.just(Mutation.setIsFetchingData(false))
            ])
            
        case .viewWillAppear:
            NotificationCenterService.configureChatTabBadgeCount.post()
            return Observable.empty()
            
        case .fetchPostList:
            
            guard
                currentState.isFetchingData == false,
                currentState.isRefreshingData == false,
                currentState.needsToFetchMoreData == true
            else { return Observable.empty() }
            
            return Observable.concat([
                Observable.just(Mutation.setIsFetchingData(true)),
                fetchPostList(at: currentState.index),
                Observable.just(Mutation.incrementIndex),
                Observable.just(Mutation.setIsFetchingData(false))
            ])
            
        case .refreshTableView:
            
            return Observable.concat([
                Observable.just(Mutation.setIsRefreshingData(true)),
                Observable.just(Mutation.setNeedsToFetchMoreData(true)),
                refreshPostList(),
                Observable.just(Mutation.incrementIndex),
                Observable.just(Mutation.setIsRefreshingData(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {
        case .setPostList(let postListModel):
            state.postList.append(contentsOf: postListModel)
        
        case .resetPostList(let postListModel):
            state.postList.removeAll()
            state.postList = postListModel
            state.index = 1
            
        case .incrementIndex:
            state.index += 1
            
        case .setUserNickname(let nickname):
            state.userNickname = nickname
            
        case .setNeedsToShowPopup(let needsToShow, let popupModel):
            state.needsToShowPopup = needsToShow
            state.popupModel = popupModel
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setIsFetchingData(let isFetchingData):
            state.isFetchingData = isFetchingData
            
        case .setIsRefreshingData(let isRefreshingData):
            state.isRefreshingData = isRefreshingData
            
        case .setNeedsToFetchMoreData(let needsToFetchMore):
            state.needsToFetchMoreData = needsToFetchMore
        
        case .empty:
            break
        }
        return state
    }
}

//MARK: - API Methods

extension PostListViewReactor {
    
    private func fetchPostList(at index: Int) -> Observable<Mutation> {
        
        return postService.fetchPostList(
            at: index,
            fetchCurrentUsers: false,
            postFilterOption: .showGatheringFirst
        )
            .asObservable()
            .map { result in
                switch result {
                case .success(let postListModel):
                    
                    return postListModel.isEmpty
                    ? Mutation.setNeedsToFetchMoreData(false)
                    : Mutation.setPostList(self.filterBannedPostUploaders(from: postListModel))
                    
                case .error(let error):
                    return error == .E601
                    ? Mutation.setNeedsToFetchMoreData(false)
                    : Mutation.setErrorMessage("오류가 발생했습니다!\n잠시 후 다시 시도해주세요.")
                }
            }
    }
    
    private func refreshPostList(postFilterOption: PostFilterOptions? = nil) -> Observable<Mutation> {
    
        return postService.fetchPostList(
            at: 1,
            fetchCurrentUsers: false,
            postFilterOption: .showGatheringFirst
        )
            .asObservable()
            .map { result in
                switch result {
                case .success(let postListModel):
                    let filteredPostListModel = self.filterBannedPostUploaders(from: postListModel)
                    return Mutation.resetPostList(filteredPostListModel)
                    
                case .error(_):
                    return Mutation.setErrorMessage(NetworkError.E000.rawValue)
                }
            }
    }
    
    private func fetchEnteredRoomInfo() -> Observable<Mutation> {
        
        return chatListService.fetchJoinedChatList()
            .asObservable()
            .map { result in
                switch result {
                case .success(_):
                    return Mutation.empty
                    
                case .error(let error):
                    print("❗️ PostListViewReactor - failed fetching entered room info with error: \(error.errorDescription)")
                    return Mutation.empty
                }
            }
    }
    
    private func loadUserProfile() -> Observable<Mutation> {
        
        return userService.loadUserProfile()
            .asObservable()
            .map { result in
                switch result {
                case .success:
                    let userNickname: String = self.userDefaultsGenericService.get(key: UserDefaults.Keys.nickname) ?? "-"
                    return Mutation.setUserNickname(userNickname)
                    
                case .error(let error):
                    return Mutation.setErrorMessage(error.errorDescription)
                }
            }
    }
    
    private func fetchLatestPopup() -> Observable<Mutation> {
        
        if !popupService.shouldFetchPopup { return Observable.empty() }
        
        return popupService.fetchLatestPopup()
            .asObservable()
            .map { result in
                switch result {
                case .success(let popupModel):
                    return Mutation.setNeedsToShowPopup(true, popupModel)
                    
                case .error(_):     //팝업 가져오기 실패 시 따로 유저한테 에러 메시지를 보여줄 필요는 없는 것으로 판단
                    print("❗️ PostListViewReactor failed fetching popup")
                    return Mutation.setNeedsToShowPopup(false, nil)
                }
            }
    }
    
    private func askForNotificationPermission() -> Observable<Mutation> {
        userNotificationService.askForNotificationPermissionAtFirstLaunch()
        return Observable.empty()
    }
}

//MARK: - Utility Methods

extension PostListViewReactor {
    
    private func filterBannedPostUploaders(from model: [PostListModel]) -> [PostListModel] {
        
        var filteredPostListModel: [PostListModel] = []
        
        model.forEach { model in
            // 차단한 유저가 포함 "안 되어"있으면 append
            if !currentState.bannedPostUploaders.contains(model.userInfo?.userUID ?? "") {
                filteredPostListModel.append(model)
            }
        }
        return filteredPostListModel
    }
}

