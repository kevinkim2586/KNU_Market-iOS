import Foundation
import UIKit


class ItemViewModel {
    
    let itemImages: [UIImage]? = [UIImage]()
    
    let itemTitle: String = ""
    
    var userProfileImage: UIImage {
        get { getUserProfileImage() }
    }
    
    let isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 3
    
    var totalGatheringPeople: Int = 5
    
    var location: String = "누리관"
    
    var itemExplanation: String = "누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬 예정입니다.누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬 예정입니다.누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬레드돔인데 같이 시키실 분? 저녁 7시에 시"
    

    init() {
 
 
    }
    
    
    func getUserProfileImage() -> UIImage {
        
        if let defaultImage = UIImage(named: "default_profile_image") {
            return defaultImage
        }
        return UIImage()
    }
    
}

