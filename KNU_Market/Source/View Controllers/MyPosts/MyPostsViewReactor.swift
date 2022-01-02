//
//  MyPostsViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift
import ReactorKit

final class MyPostsViewReactor: Reactor {
    
    let initialState: State
    let postService: PostService
    
    enum Action {
        case fetchMyPosts
        case refresh
    }
    
    enum Mutation {
        case setPostList([PostListModel])
        case resetPostList
        case setFetchingData(Bool)
        case incrementIndex
        case setNeedsToShowEmptyView(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        
        var postList: [PostListModel] = []
        
        var index: Int = 1
        
        var isFetchingData: Bool = false
        var needsToShowEmptyView: Bool = false
        var errorMessage: String?
    }
    
    init(postService: PostService) {
        self.postService = postService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .fetchMyPosts:
            
            print("✅ index: \(currentState.index)")
            
            return Observable.concat([
                Observable.just(Mutation.setFetchingData(true)),
                self.postService.fetchPostList(
                    at: currentState.index,
                    fetchCurrentUsers: true,
                    postFilterOption: .showAll
                )
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let postListModel):
                            
                            print("✅ postListModel: \(postListModel)")
                            
                            if postListModel.isEmpty {
                                return Mutation.setNeedsToShowEmptyView(true)
                                
                            }
                            
                            return Mutation.setPostList(postListModel)
                            
                        case .error(let error):
                            let errorMessage = error == .E601
                            ? "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
                            : "오류가 발생했습니다!\n잠시 후 다시 시도해주세요."
                            return Mutation.setNeedsToShowEmptyView(true)

                        }
                    },
                Observable.just(Mutation.incrementIndex),
                Observable.just(Mutation.setFetchingData(false))
            ])

            
            
        case .refresh:
            
            return Observable.concat([
                
                Observable.just(Mutation.resetPostList),
                Observable.just(Mutation.setFetchingData(false)),
                
                self.postService.fetchPostList(
                    at: currentState.index,
                    fetchCurrentUsers: true,
                    postFilterOption: .showAll
                )
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let postListModel):
                            return Mutation.setPostList(postListModel)
                            
                        case .error(let error):
                            let errorMessage = error == .E601
                            ? "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
                            : "오류가 발생했습니다!\n잠시 후 다시 시도해주세요."
                            return Mutation.setErrorMessage(errorMessage)
                        }
                    }
            ])
            
            
            
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {

        case .setPostList(let postListModel):
            print("✅ fetched posts: \(postListModel)")
            state.postList.append(contentsOf: postListModel)
            
        case .resetPostList:
            state.index = 0
            state.postList.removeAll()
            
        case .setFetchingData(let isFetchingData):
            state.isFetchingData = isFetchingData
            
        case .incrementIndex:
            state.index += 1
            
        case .setNeedsToShowEmptyView(let showEmptyView):
            state.needsToShowEmptyView = showEmptyView
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        }
        
        return state
    }
    
    
}
