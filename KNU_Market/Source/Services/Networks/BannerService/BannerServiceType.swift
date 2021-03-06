//
//  BannerServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import Foundation
import RxSwift

protocol BannerServiceType: AnyObject {
    func fetchBannerList() -> Single<NetworkResultWithArray<BannerModel>>
    func incrementBannerViewCount(bannerId: Int) -> Single<NetworkResult>
}
