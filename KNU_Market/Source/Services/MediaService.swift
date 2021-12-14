//
//  MediaService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import Foundation
import RxSwift

protocol MediaServiceType: AnyObject {
    
    func requestMedia(from imageUID: String) -> Single<NetworkResultWithValue<Data?>>
    func uploadImage(with image: Data) -> Single<NetworkResultWithValue<UploadImageResponseModel>>
    func deleteImage(uid: String) -> Single<NetworkResult>
}

class MediaService: MediaServiceType {
    
    let network: Network<MediaAPI>
    
    init(network: Network<MediaAPI>) {
        self.network = network
    }
    
    func requestMedia(from imageUID: String) -> Single<NetworkResultWithValue<Data?>> {
        
        return network.request(.requestMedia(imageUid: imageUID))
            .map {
                switch $0.statusCode {
                case 200: return .success($0.data)
                default: return .error(.E000)
                }
            }
    }
    
    func uploadImage(with image: Data) -> Single<NetworkResultWithValue<UploadImageResponseModel>> {
        
        return network.request(.uploadImage(imageData: image))
            .map {
                switch $0.statusCode {
                case 201:
                    let responseModel = try? $0.map(UploadImageResponseModel.self, using: UploadImageResponseModel.decoder)
                    guard let response = responseModel else {
                        return .error(.E000)
                    }
                    return .success(response)
                case 414:       // 너무 큰 용량의 사진 업로드 시도 시 발생하는 에러 코드
                    return .error(.E413)
                default: return .error(.E000)
                }
            }
    }
    
    func deleteImage(uid: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.deleteImage(uid: uid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    
}
