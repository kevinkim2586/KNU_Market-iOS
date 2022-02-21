//
//  PostServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift

protocol PostServiceType: AnyObject {
    
    func fetchPostList(createdAt: Int?, recruitedAt: Int?) -> Single<NetworkResultWithArray<PostModel>>
    func fetchMyPostList(userId: String, createdAt: Int?, recruitedAt: Int?) -> Single<NetworkResultWithArray<MyPostModel>>
    func uploadNewPost(with model: UploadPostRequestDTO) -> Single<NetworkResult>
    func updatePost(uid: String, with model: UploadPostRequestDTO) -> Single<NetworkResult>
    func fetchPostDetails(uid: String) -> Single<NetworkResultWithValue<PostDetailModel>>
    func deletePost(uid: String) -> Single<NetworkResult>
//    func fetchSearchResults(at index: Int, keyword: String) -> Single<NetworkResultWithArray<PostListModel>>
    func markPostDone(uid: String) -> Single<NetworkResult>
}
