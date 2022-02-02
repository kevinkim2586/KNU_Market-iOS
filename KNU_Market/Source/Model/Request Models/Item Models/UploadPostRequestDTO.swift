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
    
    static func configureDTO(
        title: String?,
        price: String?,
        shippingFee: String?,
        totalGatheringPeople: String?,
        detail: String?,
        referenceUrl: String?,
        imageUIDs: [String]?) -> UploadPostRequestDTO? {
            
            guard
                let title = title,
                let price = Int(price ?? "0"),
                let shippingFee = shippingFee == "" ? 0 : Int(shippingFee ?? "0"),
                var peopleGathering = Int(totalGatheringPeople ?? "2"),
                let detail = detail
            else { return nil }
            
            // 어쩌다가 최대 모집 인원보다 큰 숫자가 입력됐으면 강제로 10으로 설정
            if peopleGathering > ValidationError.Restrictions.maximumGatheringPeople {
                peopleGathering = ValidationError.Restrictions.maximumGatheringPeople
            }
            
            // 어쩌다가 최소 모집 인원보다 작은 숫자가 입력됐으면 강제로 2로 설정
            if peopleGathering < ValidationError.Restrictions.minimumGatheringPeople {
                peopleGathering = ValidationError.Restrictions.minimumGatheringPeople
            }
            
            return UploadPostRequestDTO(
                title: title,
                price: price,
                shippingFee: shippingFee,
                referenceUrl: referenceUrl ?? nil,
                peopleGathering: peopleGathering,
                imageUIDs: imageUIDs,
                detail: detail
            )
        }
}
