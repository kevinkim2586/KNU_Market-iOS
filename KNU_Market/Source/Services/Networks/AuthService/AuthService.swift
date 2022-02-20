//
//  AuthService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/16.
//

import Foundation
import RxSwift
import Moya

final class AuthService {
    
    static let shared = AuthService()
    
    fileprivate let network: Network<AuthAPI>
    
    private init() {
        self.network = Network<AuthAPI>()
    }
    
    func determineUserVerificationStatus() -> Bool {
        
        let rawValue: String = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.userRoleGroup) ?? UserRoleGroupType.temporary.rawValue
        
        guard let currentUserRoleGroup = UserRoleGroupType(rawValue: rawValue) else { return false }
        
        return currentUserRoleGroup == .common ? true : false
    }
    
    func determineUserRoleGroup() -> UserRoleGroupType {
        
        let rawValue: String = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.userRoleGroup) ?? ""
        
        guard let currentUserRoleGroup = UserRoleGroupType(rawValue: rawValue) else { return .temporary }
        return currentUserRoleGroup
    }
    
    func refreshToken(with refreshToken: String) -> Single<NetworkResultWithValue<LoginResponseModel>> {
        return network.requestObject(.refreshToken(refreshToken), type: LoginResponseModel.self)
            .map { result in
                print("✅ refreshToken RESULT: \(result)")
                switch result {
                case .success(let model):
                    print("✅ model: \(model) ")
                    return .success(model)
                    
                    
                case .error(let error):
                    print("❗️ error: \(error)")
                    return .error(error)
                }
            }
        
    }
}

/// 서버에서 보내주는 오류 문구 파싱용
extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func handleResponse() -> Single<Element> {
        return flatMap { response in
            print("✅ handling response..\(response)")
            // 토큰 재발급 받았을 때 토큰 변경함
            
            if let tokenModel = try? response.map(LoginResponseModel.self) {
                print("✅ tokenModel: \(tokenModel)")
                UserDefaultsGenericService.shared.set(
                    key: UserDefaults.Keys.accessToken,
                    value: tokenModel.accessToken
                )
                UserDefaultsGenericService.shared.set(
                    key: UserDefaults.Keys.refreshToken,
                    value: tokenModel.refreshToken
                )
            }
            
            if (200 ... 299) ~= response.statusCode {
                return Single.just(response)
            }
            
            if var error = try? response.map(ResponseError.self) {
                print("❗️ HandleResponse Error: \(error)")
                error.statusCode = response.statusCode
                return Single.error(error)
            }
            
            // Its an error and can't decode error details from server, push generic message
            let genericError = ResponseError(
                statusCode: 404,
                message: "일시적인 서비스 오류입니다.😢 잠시 후 다시 시도해주세요."
            )
            
            return Single.error(genericError)
        }
    }
}

