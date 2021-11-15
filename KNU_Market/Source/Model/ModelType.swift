//
//  ModelType.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import Foundation
import Then

protocol ModelType: Codable ,Then {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy { get }
}

extension ModelType {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy {
        let formatter = DateFormatter()
        // date format for KNU
//        formatter.dateFormat = "yyyy-MM-dd"
        return .formatted(formatter)
    }
    
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = self.dateDecodingStrategy
        return decoder
    }
    
}
