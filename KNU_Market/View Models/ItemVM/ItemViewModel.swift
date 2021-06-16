import Foundation
import UIKit

protocol ItemViewModelDelegate {
    func didFetchPostDetails()
    func failedFetchingPostDetails(with error: NetworkError)
}


class ItemViewModel {
    
    //TODO - 이렇게 변수 다 따로따로 하지 말고, 받아오는 정보 (JSON)에 해당하는 구조체 하나 만들어서 한꺼번에 받기
    
    var delegate: ItemViewModelDelegate?
    
    let itemImages: [UIImage]? = [UIImage]()
    
    let itemTitle: String = ""
    
    var userProfileImage: UIImage {
        get { getUserProfileImage() }
    }
    
    let isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 1
    
    var totalGatheringPeople: Int = 5
    
    var location: String = ""
    
    var itemExplanation: String = ""
    

    init() {
 
 
    }
    
    func fetchPostDetails() {
        
        
        
    }
    
    
    func getUserProfileImage() -> UIImage {
        
        if let defaultImage = UIImage(named: "default avatar") {
            return defaultImage
        }
        return UIImage()
    }
    
}

