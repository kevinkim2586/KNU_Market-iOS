//
//  PostAPI.swift
//  
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import Moya

enum PostAPI {
    case fetchPostList(fetchCurrentUsers: Bool = false)
    case uploadNewPost(model: UploadPostRequestDTO)
    case updatePost(uid: String, model: UploadPostRequestDTO)
    case fetchPostDetails(uid: String)
    case deletePost(uid: String)
    case markPostDone(uid: String)
}

extension PostAPI: BaseAPI {
    
    var path: String {
        switch self {
     
        case let .fetchPostList(fetchCurrentUsers):
            return fetchCurrentUsers == true
            ? "posts/users/"
            : "posts"
        case .uploadNewPost:
            return "posts"
        case let .updatePost(uid, _), let .fetchPostDetails(uid), let .deletePost(uid):
            return "posts/\(uid)"
        case let .markPostDone(uid):
            return "posts/complete/\(uid)"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadNewPost, .updatePost:
            return ["Content-Type" : "multipart/form-data"]
        default:
            return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchPostList, .fetchPostDetails:
            return .get
        case .uploadNewPost:
            return .post
        case .updatePost:
            return .patch
        case .markPostDone:
            return .put
        case .deletePost:
            return .delete
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .fetchPostList:
//            return [ "page" : index ]
            return nil
        default: return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .fetchPostList:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
            
        case let .uploadNewPost(model), let .updatePost(_, model):
            
            var multipartData: [MultipartFormData] = []
            
            multipartData.append(MultipartFormData(provider: .data(model.title.data(using: .utf8)!), name: "title"))
            multipartData.append(MultipartFormData(provider: .data(model.content.data(using: .utf8)!), name: "content"))
            multipartData.append(MultipartFormData(provider: .data(String(model.location).data(using: .utf8)!), name: "location"))
            multipartData.append(MultipartFormData(provider:.data(String(model.headCount).data(using: .utf8)!), name: "headCount"))
            multipartData.append(MultipartFormData(provider: .data(String(model.price).data(using: .utf8)!), name: "price"))
            multipartData.append(MultipartFormData(provider: .data(String(model.shippingFee).data(using: .utf8)!), name: "shippingFee"))
            
            if let referenceUrl = model.referenceUrl {
                multipartData.append(MultipartFormData(provider: .data(referenceUrl.data(using: .utf8)!), name: "referenceUrl"))
            }
            
            if let images = model.images {
                for image in images {
                    multipartData.append(MultipartFormData(provider: .data(image), name: "postFile", fileName: "postImage_\(UUID().uuidString).jpeg", mimeType: "image/jpeg"))
                }
            }
            
            return .uploadMultipart(multipartData)
            
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }    
}
