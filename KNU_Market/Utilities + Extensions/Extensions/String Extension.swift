import Foundation

extension String {
    
    func convertStringToDate() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let date: Date = dateFormatter.date(from: self) ?? Date()
        print("✏️ date: \(date)")
        return date
    }
}
