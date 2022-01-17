//
//  DateFormatter.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/13.
//

import Foundation

struct DateConverter {
    
    static func convertDateToIncludeTodayAndYesterday(_ date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.DateFormat.defaultFormat
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
    
    
    static func convertDateForPostTVC(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        


        let dateString = date.toStringWithRelativeTime()

  
        return dateString
    }
    
    
    
    
    
}
