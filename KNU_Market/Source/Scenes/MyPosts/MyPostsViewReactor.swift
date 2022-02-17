//
//  MyPostsViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

final class MyPostsViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let postService: PostServiceType
    
    enum Action {
        case fetchMyPosts
        case seePostDetail(IndexPath)
        case refresh
    }
    
    enum Mutation {
        case setPostList([PostModel])
        case resetPostList([PostModel])
        case setFetchingData(Bool)
        case incrementIndex
        case setNeedsToShowEmptyView(Bool)
        case setNeedsToFetchMoreData(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var postList: [PostModel] = []
        var index: Int = 1
        var isFetchingData: Bool = false

        var needsToShowEmptyView: Bool = false
        var needsToFetchMoreData: Bool = true
        var errorMessage: String?
    }
    
    init(postService: PostServiceType) {
        self.postService = postService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .fetchMyPosts:
            
            guard currentState.needsToFetchMoreData == true else { return Observable.empty() }
            guard currentState.isFetchingData == false else { return Observable.empty() }
        
            return Observable.concat([
                
                Observable.just(Mutation.setFetchingData(true)),
                
                self.postService.fetchPostList(
                    fetchCurrentUsers: true
                )
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let postListModel):
                            return postListModel[0].posts.isEmpty
                            ? Mutation.setNeedsToFetchMoreData(false)
                            : Mutation.setPostList(postListModel[0].posts)
                            
                        case .error(let error):
                            return error == .E601
                            ? Mutation.setNeedsToShowEmptyView(true)
                            : Mutation.setErrorMessage("오류가 발생했습니다!\n잠시 후 다시 시도해주세요.")
                        }
                    },
                Observable.just(Mutation.incrementIndex),
                Observable.just(Mutation.setFetchingData(false))
            ])
            
        case .seePostDetail(let indexPath):
            
            self.steps.accept(AppStep.postIsPicked(
                postUid: currentState.postList[indexPath.row].postID,
                isFromChatVC: false)
            )
            return .empty()
            
        case .refresh:
                    
            return Observable.concat([
            
                Observable.just(Mutation.setFetchingData(true)),
                
                self.postService.fetchPostList(      
                    fetchCurrentUsers: true
                )
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let postListModel):
                            return Mutation.resetPostList(postListModel[0].posts)
                            
                        case .error(let error):
                            let errorMessage = error == .E601
                            ? "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
                            : "오류가 발생했습니다!\n잠시 후 다시 시도해주세요."
                            return Mutation.setErrorMessage(errorMessage)
                        }
                    },
                
                Observable.just(Mutation.setFetchingData(false)),
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        state.needsToShowEmptyView = false
        
        switch mutation {

        case .setPostList(let postListModel):
            state.postList.append(contentsOf: postListModel)
            
        case .resetPostList(let postListModel):
            state.postList.removeAll()
            state.postList.append(contentsOf: postListModel)
            
        case .setFetchingData(let isFetchingData):
            state.isFetchingData = isFetchingData

        case .incrementIndex:
            state.index += 1
            
        case .setNeedsToFetchMoreData(let needsToFetchMoreData):
            state.needsToFetchMoreData = needsToFetchMoreData
            
        case .setNeedsToShowEmptyView(let showEmptyView):
            state.needsToShowEmptyView = showEmptyView
            state.needsToFetchMoreData = false
            state.isFetchingData = false
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            state.isFetchingData = false
            state.needsToFetchMoreData = false
        }
        return state
    }
}


