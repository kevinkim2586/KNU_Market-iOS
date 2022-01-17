//
//  BannerService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import Foundation
import RxSwift

final class BannerService: BannerServiceType {

    fileprivate let network: Network<BannerAPI>
    
    init(network: Network<BannerAPI>) {
        self.network = network
    }
    
    func fetchBannerList() -> Single<NetworkResultWithArray<BannerModel>> {
        
        return network.requestArray(.fetchBannerList, type: BannerModel.self)
            .map { result in
                switch result {
                case .success(let bannerModel):
                    return .success(bannerModel)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func incrementBannerViewCount(bannerId: Int) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.incrementBannerViewCount(bannerId: bannerId))
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
