import UIKit

class ItemTableViewModel {
    
    var itemImage: UIImage? = UIImage(named: "pizza")!
    
    
    
    var title: String = "6시에 피자 같아 시키실 분?"
  
    var isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 2
    
    var totalGatheringPeople: Int = 4
    
    var location: String = "테크노문"
    
    init() {
        
        
    }
    
    
    
}
