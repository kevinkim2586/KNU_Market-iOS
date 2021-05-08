import Foundation
import UIKit


class ItemViewModel {
    
    //MARK: - Object Properties
    
    let itemImages: [UIImage]?
    
    let itemTitle: String
    
    var userProfileImage: UIImage {
        get { getUserProfileImage() }
    }
    
    let isGathering: Bool
    
    
    
    
    //MARK: - Initialization
    
    init() {
        
        self.itemTitle = ""
        self.isGathering = false
        self.itemImages = [UIImage]()
        
    }
    
    
    func getUserProfileImage() -> UIImage {
        
        if let defaultImage = UIImage(named: "default_profile_image") {
            return defaultImage
        }
        return UIImage()
    }
    
}

