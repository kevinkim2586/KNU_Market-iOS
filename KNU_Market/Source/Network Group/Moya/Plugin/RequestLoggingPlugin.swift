//
//  RequestLoggingPlugin.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation

import Moya

/// 네트워크 호출 결과 로그 표시
final class RequestLoggingPlugin: PluginType {
    /// API를 보내기 직전에 호출
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("➡️ INVALID REQUEST")
            return
        }

        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"

        var log = "➡️ \(method) \(url)\n"
        log.append("API: \(target)\n")

        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header: \(headers)\n")
        }

        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            log.append("\(bodyString)\n")
        }

        log.append("➡️ END \(method)")
        print(log)
    }

    /// API Response
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }

    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode

        var log = "⬅️ \(statusCode) \(url)\n"
        log.append("API: \(target)\n")

        response.response?.allHeaderFields.forEach {
            log.append("\($0): \($1)\n")
        }

        if let reString = String(bytes: response.data, encoding: String.Encoding.utf8) {
            log.append("\(reString)\n")
        }

        log.append("⬅️ END HTTP (\(response.data.count)-byte body)")
        print(log)
    }

    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSuceed(response, target: target, isFromError: true)
            return
        }

        var log = "⬅️ \(error.errorCode) \(target)\n"
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("⬅️ END HTTP")
        print(log)
    }
}
