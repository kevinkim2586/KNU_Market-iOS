import UIKit

class ItemTableViewModel {
    
    var uuid: String = ""
    
    var itemImage: UIImage? = UIImage(named: "default item icon")!
    
    var imageUIDs: String = ""
    
    
    var title: String = "6시에 피자 같아 시키실 분?"
  
    var isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 2
    
    var totalGatheringPeople: Int = 4
    
    var location: Int = 0
    
    var locationName: String {
        get { return Location.list[location] }
    }
    
    init() {
        
        
    }
    
    
    
}
