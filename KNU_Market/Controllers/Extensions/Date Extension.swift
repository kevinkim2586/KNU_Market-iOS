import Foundation

extension Date {
    
    func formatToString(from date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        let date = formatter.string(from: date)
        return date
    }
}

