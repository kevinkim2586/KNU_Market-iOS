import UIKit

class ItemTableViewModel {
    
    var uuid: String = ""

    var defaultImage: UIImage = UIImage(named: Constants.Images.defaultItemIcon)!
    
    var imageUID: String = "" {
        didSet {
            imageURL = URL(string: "\(Constants.API_BASE_URL)media/" + imageUID)
        }
    }
    
    var imageURL: URL?
    
    var title: String = ""
  
    var isGathering: Bool {
        return currentlyGatheredPeople != totalGatheringPeople
    }
    
    var currentlyGatheredPeople: Int = 1
    
    var totalGatheringPeople: Int = 4
    
    var location: Int = 0
    
    var locationName: String {
        return Location.listForCell[location]
    }
    
    private var formattedDate: String = ""
    var date: String {
        get {
            return formattedDate
        }
        set {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateFormatter.locale = Locale(identifier:"ko_KR")
            let convertedDate = dateFormatter.date(from: newValue)
           
            dateFormatter.dateFormat = "MM/dd\nHH:mm"
            
            if let date = convertedDate {
                let finalDate = dateFormatter.string(from: date)
                formattedDate = finalDate
            } else {
                formattedDate = "날짜 표시 에러"
            }
        }
    }
    
 
    
    
}
