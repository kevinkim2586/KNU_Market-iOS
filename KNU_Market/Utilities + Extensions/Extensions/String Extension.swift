import Foundation

extension String {
    
    func convertStringToDate() -> Date {
        
        print("✏️ date string: \(self)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: self) else {
            return Date()
        }
        return convertedDate
    }
}
