//
//  MediaAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/13.
//

import Foundation
import Alamofire
import Moya

enum MediaAPI {
    case requestMedia(imageUid: String)
    case uploadImage(imageData: Data)
    case deleteImage(uid: String)
}

extension MediaAPI: BaseAPI {
    
    var path: String {
        switch self {
        case let .requestMedia(imageUid), let .deleteImage(imageUid):
            return "media/\(imageUid)"
        case .uploadImage:
            return "media"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        default: return ["Content-Type" : "application/json"]
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestMedia:
            return .get
        case .uploadImage:
            return .post
        case .deleteImage:
            return .delete
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
            
        default: return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default: return JSONEncoding.default
        }
    }
    
    var task: Task {
        switch self {
            
        case let .uploadImage(imageData: imageData):
            let multipartData = MultipartFormData(provider: .data(imageData), name: "media", fileName: "newImage.jpeg", mimeType: "image/jpeg")
            return .uploadMultipart([multipartData])
            
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
