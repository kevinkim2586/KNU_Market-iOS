import Foundation

extension Date {
    
    // Chat Bubble용 format 방법
    func formatToString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        let date = formatter.string(from: self)
        return date
    }
}

