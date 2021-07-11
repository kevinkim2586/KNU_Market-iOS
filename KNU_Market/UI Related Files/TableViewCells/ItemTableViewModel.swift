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
    
    var date: String
    
 
    
    
}
