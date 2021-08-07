import Foundation

extension String {
    
    func convertStringToDate() -> Date {
        
        print("✏️ date string: \(self)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: self) else {
            return Date()
        }
        
        
        
        dateFormatter.dateFormat = "MM/dd HH:mm"

        let date: Date = dateFormatter.date(from: self) ?? Date()
        print("✏️ date: \(date)")
        return date
    }
}
