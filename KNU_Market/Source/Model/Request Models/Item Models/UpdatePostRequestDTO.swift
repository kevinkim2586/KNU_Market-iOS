import Foundation
import Alamofire

struct UpdatePostRequestDTO {
    
    var parameters: Parameters = [:]
    
    init(
        title: String,
        location: Int = Location.list.count,
        detail: String,
        imageUIDs: [String],
        totalGatheringPeople: Int,
        currentlyGatheredPeople: Int,
        isCompletelyDone: Bool? = nil,
        referenceUrl: String?,
        shippingFee: Int?,
        price: Int
    ) {
        
        parameters["title"] = title
        parameters["spotCategory"] = location
        parameters["content"] = detail
        parameters["maxHeadcount"] = totalGatheringPeople
        parameters["currentHeadcount"] = currentlyGatheredPeople
        parameters["image"] = imageUIDs
        parameters["price"] = price
        
        if let referenceUrl = referenceUrl {
            parameters["referenceUrl"] = referenceUrl
        }
        
        if let shippingFee = shippingFee {
            parameters["shippingFee"] = shippingFee
        }
    
        if isCompletelyDone != nil {
            parameters["isArchived"] = isCompletelyDone
        }
    }
}
