//
//  Network.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

import RxSwift
import Moya

class Network<API: TargetType>: MoyaProvider<API> {
    
    init(plugins: [PluginType] = []) {
        let session = MoyaProvider<API>.defaultAlamofireSession()
        // set Timeout
        session.sessionConfiguration.timeoutIntervalForRequest = 10
        
        super.init(session: session, plugins: plugins)
    }
    
    func request(_ api: API) -> Single<Response> {
        return self.rx.request(api)
            .filter(statusCodes: 200...500)
    }
}

extension Network {
    func requestObject<T: ModelType>(_ target: API, type: T.Type) -> Single<NetworkResultWithValue<T>> {
        let decoder = type.decoder
        return request(target)
            .map { result in
                let response = try? result.map(T.self, using: decoder)
                guard let response = response else {
                    return .error(NetworkError.returnError(json: result.data))
                }
                return .success(response)
            }
    }
    
    func requestArray<T: ModelType>(_ target: API, type: T.Type) -> Single<NetworkResultWithArray<T>> {
        let decoder = type.decoder
        return request(target)
            .map { result in
                let response = try? result.map([T].self, using: decoder)
                guard let response = response else {
                    return .error(NetworkError.returnError(json: result.data))
                }
                return .success(response)
            }
    }
    
    func requestWithoutMapping(_ target: API) -> Single<NetworkResult> {
        return request(target)
            .map { result in
                if (400...500).contains(result.statusCode) {
                    return .error(NetworkError.returnError(json: result.data))
                }
                return .success
            }
    }

}
