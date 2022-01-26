import Foundation
import Alamofire

struct UploadPostRequestDTO {
    var parameters: Parameters = [:]
    
    init(
        title: String,
        price: Int,
        shippingFee: Int,
        referenceUrl: String?,
        peopleGathering: Int,
        imageUIDs: [String]?,
        detail: String,
        location: Int = Location.list.count              // v1.3까지는 default 8 == 협의
    ) {
    
        parameters["title"] = title
        parameters["price"] = price
        parameters["shippingFee"] = shippingFee
        parameters["recruitment"] = peopleGathering
        parameters["spotCategory"] = location
        parameters["content"] = detail
        
        if let referenceUrl = referenceUrl {
            parameters["referenceUrl"] = referenceUrl
        }

        if let imageUIDs = imageUIDs {
            parameters["image"] = imageUIDs
        }
    }
}
