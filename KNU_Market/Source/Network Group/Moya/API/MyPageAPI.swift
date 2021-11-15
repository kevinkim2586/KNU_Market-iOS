//
//  MyPageAPI.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

import Foundation
import Moya

enum MyPageAPI {
    case writeReport(String, String, Data?, Data?)
}

extension MyPageAPI: BaseAPI {
    
    var path: String {
        switch self {
        case .writeReport:
            return "/user/report"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .writeReport:
            return [
                "Content-Type" : "multipart/form-data"
            ]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .writeReport:
            return .post
        }
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var task: Task {
        
        switch self {
        case let .writeReport(title, content, media1, media2):
            var multipartData: [MultipartFormData] = []
            
            // title, content
            multipartData.append(MultipartFormData(provider: .data(title.data(using: .utf8)!), name: "title"))
            multipartData.append(MultipartFormData(provider: .data(content.data(using: .utf8)!), name: "content"))
            
            // add medias
            if let media1 = media1 {
                multipartData.append(MultipartFormData(provider: .data(media1), name: "medias", fileName: "file.jpg", mimeType: "image/jpg"))
            }
            if let media2 = media2 {
                multipartData.append(MultipartFormData(provider: .data(media2), name: "medias", fileName: "file.jpg", mimeType: "image/jpg"))
            }
            
            return .uploadMultipart(multipartData)
            
//        default:
//            if let parameters = parameters {
//                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
//            }
//            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .none
    }
}
