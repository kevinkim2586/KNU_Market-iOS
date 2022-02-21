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
        case isoDateTimeMilliSec

        var stringFormat: String {
            switch self {
            case .isoDateTimeMilliSec:
                return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
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
        dateFormatter.dateFormat = DateFormatType.isoDateTimeMilliSec.stringFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: dateString) else {
            return "-"
        }
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter.string(from: convertedDate)
    }
    
    static func convertDateStringToComplex(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.isoDateTimeMilliSec.stringFormat
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: dateString) else {
            return "-"
        }
        return convertedDate.toStringWithRelativeTime()
    }
    
    // recruitedAt이 nil일 수 있어 내부가 String Optional로 설정
    static func convertDatesToTimeStamps(dates: [String?]) -> [Int?] {
        
        var timeStampArray: [Int?] = []
        
        for date in dates {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = self.DateFormatType.isoDateTimeMilliSec.stringFormat
            
            
            guard let convertedDate = dateFormatter.date(from: date ?? "") else {
                timeStampArray.append(nil)
                continue
            }
            
            let timeStamp: TimeInterval = convertedDate.timeIntervalSince1970
            let dateInInteger: Int = Int(timeStamp)
            timeStampArray.append(dateInInteger)
        }
        return timeStampArray
    }
}
