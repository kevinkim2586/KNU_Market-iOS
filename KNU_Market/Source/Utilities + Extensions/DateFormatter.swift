//
//  DateFormatter.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/13.
//

import Foundation


struct DateConverter {
    
    enum DateFormatType {
        case simple

        var stringFormat: String {
            switch self {
            case .simple: return "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
    
    static func convertDateToIncludeTodayAndYesterday(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.simple.stringFormat
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: date) else {
            return "날짜 표시 에러"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(convertedDate) {
            dateFormatter.dateFormat = "오늘 HH:mm"
            return dateFormatter.string(from: convertedDate)
        } else if calendar.isDateInYesterday(convertedDate) {
            dateFormatter.dateFormat = "어제 HH:mm"
            return dateFormatter.string(from: convertedDate)
        } else {
            dateFormatter.dateFormat = "MM/dd HH:mm"
            return dateFormatter.string(from: convertedDate)
        }
    }
    
    static func convertDateStringToSimpleFormat(_ dateString: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.simple.stringFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: dateString) else {
            return "-"
        }
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter.string(from: convertedDate)
    }
    
    static func convertDateStringToComplex(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.simple.stringFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: dateString) else {
            return "-"
        }
        return convertedDate.toStringWithRelativeTime()
    }
}
