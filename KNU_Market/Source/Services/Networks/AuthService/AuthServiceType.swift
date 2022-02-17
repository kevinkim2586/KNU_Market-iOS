//
//  AuthServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/16.
//

import Foundation
import RxSwift
import Moya

protocol AuthServiceType: AnyObject {
    func refreshToken(with refreshToken: String) -> Single<Response>
}
