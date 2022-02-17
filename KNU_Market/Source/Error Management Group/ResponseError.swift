//
//  ResponseError.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/16.
//

import Foundation

struct ResponseError: Decodable, Error {
    var statusCode: Int
    var message: String
    var error: String?
}
