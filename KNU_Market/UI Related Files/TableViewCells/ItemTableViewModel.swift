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
  
    var isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 1 {
        didSet {
            if currentlyGatheredPeople == totalGatheringPeople {
                isGathering = false
            }
        }
    }
    
    var totalGatheringPeople: Int = 4
    
    var location: Int = 0
    
    var locationName: String {
        get { return Location.listForCell[location] }
    }
    
    private var formattedDate: String = ""
    var date: String {
        get {
            return formattedDate
        }
        set {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let convertedDate = dateFormatter.date(from: newValue)
            
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            if let date = convertedDate {
                let finalDate = dateFormatter.string(from: date)
                formattedDate = finalDate
            }
            formattedDate = "날짜 표시 에러"
            
        }
    }
    
 
    
    
}
