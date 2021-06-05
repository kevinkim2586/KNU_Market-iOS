import Foundation
import UIKit


class ItemViewModel {
    
    //TODO - 이렇게 변수 다 따로따로 하지 말고, 받아오는 정보 (JSON)에 해당하는 구조체 하나 만들어서 한꺼번에 받기
    
    let itemImages: [UIImage]? = [UIImage]()
    
    let itemTitle: String = ""
    
    var userProfileImage: UIImage {
        get { getUserProfileImage() }
    }
    
    let isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 3
    
    var totalGatheringPeople: Int = 5
    
    var location: String = "누리관"
    
    var itemExplanation: String = "누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬 예정입니다. 최소주문금액 15000원 정도 예상합니다!"
    

    init() {
 
 
    }
    
    
    func getUserProfileImage() -> UIImage {
        
        if let defaultImage = UIImage(named: "default avatar") {
            return defaultImage
        }
        return UIImage()
    }
    
}

