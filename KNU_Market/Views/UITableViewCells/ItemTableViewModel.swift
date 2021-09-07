import UIKit

class ItemTableViewModel {
    
    var uuid: String = ""

    var defaultImage: UIImage = UIImage(named: Constants.Images.defaultItemIcon)!
    
    var imageUID: String? {
        didSet {
            if let imageUID = imageUID {
                imageURL = URL(string: "\(Constants.API_BASE_URL)media/" + imageUID)
            }
            
        }
    }
    
    var imageURL: URL?
    
    var title: String = ""
  
    var isFull: Bool = false
    
    var isCompletelyDone: Bool = false
    
    var currentlyGatheredPeople: Int = 1
    
    var totalGatheringPeople: Int = 4
    
    var location: Int = 0
    
    var locationName: String {
        
        let index = location - 1
        guard index != Location.list.count + 1 else {
            return Location.listForCell[Location.listForCell.count - 1]
        }
        return Location.listForCell[location - 1]
    }
    
    private var formattedDate: String = ""
    var date: String {
        get {
            return formattedDate
        }
        set {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier:"ko_KR")
            guard let convertedDate = dateFormatter.date(from: newValue) else {
                formattedDate = "날짜 표시 에러"
                return
            }
            let calendar = Calendar.current
            
            if calendar.isDateInToday(convertedDate) {
                dateFormatter.dateFormat = "오늘\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            } else if calendar.isDateInYesterday(convertedDate) {
                dateFormatter.dateFormat = "어제\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            } else {
                dateFormatter.dateFormat = "MM/dd\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            }
        }
    }
    
 
    
    
}
