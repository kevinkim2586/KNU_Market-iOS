//
//  PostAPI.swift
//  
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import Moya

enum PostAPI {
    case fetchPostList(index: Int, fetchCurrentUsers: Bool = false, postFilterOption: PostFilterOptions)
    case uploadNewPost(model: UploadPostRequestDTO)
    case updatePost(uid: String, model: UpdatePostRequestDTO)
    case fetchPostDetails(uid: String)
    case deletePost(uid: String)
    case fetchSearchResults(index: Int, keyword: String)
    case markPostDone(uid: String)
}

extension PostAPI: BaseAPI {
    
    var path: String {
        switch self {
        case let .fetchPostList(index, fetchCurrentUsers, _):
            return fetchCurrentUsers == true
            ? "posts/me?page=\(index)"
            : "posts?page=\(index)"
        case .uploadNewPost:
            return "posts"
        case let .updatePost(uid, _), let .fetchPostDetails(uid), let .deletePost(uid):
            return "posts/\(uid)"
        case .fetchSearchResults:
            return "search"
        case let .markPostDone(uid):
            return "posts/complete/\(uid)"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case let .fetchPostList(_, _, postFilterOptions):
            if postFilterOptions == .showGatheringFirst {
                return ["withoutcomplete" : "1"]
            } else { fallthrough }
        default: return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchPostList, .fetchPostDetails, .fetchSearchResults:
            return .get
        case .uploadNewPost:
            return .post
        case .updatePost, .markPostDone:
            return .put
        case .deletePost:
            return .delete
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .uploadNewPost(model: model):
            return model.parameters
        case let .updatePost(_, model: model):
            return model.parameters
        case let .fetchSearchResults(index, keyword):
            return [
                "keyword" : keyword,
                "page" : index
            ]
        default: return nil
        }
    }
    
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .fetchSearchResults:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }    
}
