import Foundation

extension Date {
    
    // Chat Bubble용 format 방법
    func getDateStringForChatBottomLabel() -> String {
        
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
    
    func getDateStringForGetChatListHeader() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
}
