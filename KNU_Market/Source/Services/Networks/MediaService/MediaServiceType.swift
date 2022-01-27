//
//  MediaServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift

protocol MediaServiceType: AnyObject {
    func requestMedia(from imageUID: String) -> Single<NetworkResultWithValue<Data?>>
    func uploadImage(with image: Data) -> Single<NetworkResultWithValue<UploadImageResponseModel>>
    func deleteImage(uid: String) -> Single<NetworkResult>
}
