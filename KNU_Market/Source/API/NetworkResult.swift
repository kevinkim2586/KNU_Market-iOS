//
//  NetworkResult.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

enum NetworkResult {
    case success
    case error(NetworkError)
}

enum NetworkResultWithValue<T> {
    case success(T)
    case error(NetworkError)
}

enum NetworkResultWithArray<T> {
    case success([T])
    case error(NetworkError)
}
