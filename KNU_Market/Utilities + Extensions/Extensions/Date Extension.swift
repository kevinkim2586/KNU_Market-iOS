import Foundation

extension Date {
    
    // Chat Bubble용 format 방법
    func getFormattedDate() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        if self.compare(.isToday) {
            
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: self)
            
        } else if self.compare(.isYesterday) {
            
            dateFormatter.dateFormat = "어제 HH:mm"
            return dateFormatter.string(from: self)
            
        } else {
            
            dateFormatter.date(from: "MM/dd HH:mm")
            return dateFormatter.string(from: self)
        }
    }
}
