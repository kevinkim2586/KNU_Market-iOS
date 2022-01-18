//
//  Int+Extension.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/18.
//

import Foundation

extension Int {
    
    var withDecimalSeparator: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: self))!
        return result
    }
}

