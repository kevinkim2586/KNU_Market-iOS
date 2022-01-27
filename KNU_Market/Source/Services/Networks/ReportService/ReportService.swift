//
//  ReportService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import Foundation
import RxSwift

final class ReportService: ReportServiceType {
    
    fileprivate let network: Network<ReportAPI>
    
    init(network: Network<ReportAPI>) {
        self.network = network
    }
    
    func reportUser(with model: ReportUserRequestDTO) -> Single<NetworkResult> {
        return network.requestWithoutMapping(.reportUser(model: model))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
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
