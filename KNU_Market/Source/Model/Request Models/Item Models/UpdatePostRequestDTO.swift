import Foundation
import Alamofire

struct UpdatePostRequestDTO {
    
    var parameters: Parameters = [:]
    
    init(
        title: String,
        location: Int = Location.list.count,
        detail: String,
        imageUIDs: [String]?,
        totalGatheringPeople: Int,
        currentlyGatheredPeople: Int,
        isCompletelyDone: Bool? = nil,
        referenceUrl: String?,
        shippingFee: Int?,
        price: Int?
    ) {
        
        parameters["title"] = title
        parameters["spotCategory"] = location
        parameters["content"] = detail
        parameters["maxHeadcount"] = totalGatheringPeople
        parameters["currentHeadcount"] = currentlyGatheredPeople
        parameters["image"] = imageUIDs ?? []
        parameters["price"] = price ?? 0
        
        parameters["referenceUrl"] = referenceUrl ?? nil
        parameters["shippingFee"] = shippingFee ?? 0

   
        if isCompletelyDone != nil {
            parameters["isArchived"] = isCompletelyDone
        }
    }
}
