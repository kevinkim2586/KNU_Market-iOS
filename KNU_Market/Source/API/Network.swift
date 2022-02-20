//
//  Network.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation
import RxSwift
import Moya
import SwiftyJSON

enum TokenError: Error {
    case tokenExpired
}

class Network<API: TargetType>: MoyaProvider<API> {
    
    init(plugins: [PluginType] = []) {
        let session = MoyaProvider<API>.defaultAlamofireSession()
        // set Timeout
        session.sessionConfiguration.timeoutIntervalForRequest = 10
        
        super.init(session: session, plugins: plugins)
    }
    
    func request(_ api: API) -> Single<Response> {
        return self.rx.request(api)
//            .flatMap { response in
//                print("✅ Network flatMap: \(response)")
//                if response.statusCode == 401 {             // 401 == Unauthorized Error 전용 -> 토큰 만료
//                    throw TokenError.tokenExpired
//                } else {
//                    return Single.just(response)
//                }
//            }
//            .retry(when: { (error: Observable<TokenError>) in
//                error.flatMap { error -> Single<NetworkResultWithValue<LoginResponseModel>> in
//                    print("❗️ Retrying...")
//                     return AuthService.shared.refreshToken(with: User.shared.refreshToken)
//
//                }
//            })
//            .handleResponse()
            .filter(statusCodes: 200...500)
//            .retry(2)
    }
    
//    func request(_ api: API) -> Single<Response> {
//        return self.rx.request(api)
//            .filter(statusCodes: 200...500)
//    }
}

extension Network {
    
    func requestObject<T: ModelType>(_ target: API, type: T.Type) -> Single<NetworkResultWithValue<T>> {
        let decoder = type.decoder
        return request(target)
            .map { result in
                print("✅ result status code: \(result.statusCode), for target: \(target)")

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
                print("✅ result status code: \(result.statusCode), for target: \(target)")
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
                print("✅ result status code: \(result.statusCode), for target: \(target)")
                if (400...500).contains(result.statusCode) {
                    return .error(NetworkError.returnError(json: result.data))
                }
                return .success
            }
    }
    
    func requestRawJsonWithArray<T: ModelType>(_ target: API, type: T.Type) -> Single<NetworkResultWithArray<T>> {
        let decoder = type.decoder
        return request(target)
            .map { result in
                print("✅ result status code: \(result.statusCode), for target: \(target)")
                do {
                    let entireJSON = try JSON(data: result.data)
                    let requiredJSONData = try entireJSON[0].rawData()
                    let model = try decoder.decode([T].self, from: requiredJSONData)
                    return .success(model)
                } catch {
                    print("❗️ Error in requestRawJsonWithArray: \(error)")
                    return .error(.E000)
                }
            }
    }
}
