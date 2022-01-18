//
//  UIColor+Extension.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/18.
//

import UIKit

extension UIColor {
    
    //var color1 = UIColor.convertUsingHexString("#d3d3d3")
    static func convertUsingHexString(hexValue: String) -> UIColor {
        var cString:String = hexValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
