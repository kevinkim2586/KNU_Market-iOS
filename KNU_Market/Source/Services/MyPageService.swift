//
//  MyPageService.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

import RxSwift

protocol MyPageServiceType: AnyObject {
    func writeReport(_ title: String, _ content: String, _ media1: Data?, _ media2: Data?) -> Single<NetworkResult>
    func viewMessage(_ uid: Int) -> Single<NetworkResult>
}

class MyPageService: MyPageServiceType {
    
    fileprivate let network: Network<MyPageAPI>
    
    init(network: Network<MyPageAPI>) {
        self.network = network
    }
    
    func writeReport(_ title: String, _ content: String, _ media1: Data?, _ media2: Data?) -> Single<NetworkResult> {
        return network.requestWithoutMapping(.writeReport(title, content, media1, media2))
            .map { result in
                switch result {
                case .success:
                    return .success
                case let .error(error):
                    return .error(error)
                }
            }
    }
    
    func viewMessage(_ uid: Int) -> Single<NetworkResult> {
        return network.requestWithoutMapping(.viewReport(uid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case let .error(error):
                    return .error(error)
                }
            }
    }
    
}
