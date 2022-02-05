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
    

    static func configureStandardDTO(
        title: String?,
        detail: String?,
        imageUids: [String],
        totalGatheringPeople: String?,
        currentlyGatheredPeople: Int?,
        referenceUrl: String?,
        shippingFee: String?,
        price: String?
    ) -> UpdatePostRequestDTO? {
        
        guard
            let title = title,
            let detail = detail,
            var totalGatheringPeople = Int(totalGatheringPeople ?? "2"),
            let currentlyGatheredPeople = currentlyGatheredPeople,
            let referenceUrl = referenceUrl,
            let shippingFee = shippingFee == "" ? 0 : Int(shippingFee ?? "0"),
            let price = Int(price ?? "0")
        else { return nil }
        
        // 어쩌다가 최대 모집 인원보다 큰 숫자가 입력됐으면 강제로 10으로 설정
        if totalGatheringPeople > ValidationError.Restrictions.maximumGatheringPeople {
            totalGatheringPeople = ValidationError.Restrictions.maximumGatheringPeople
        }
        
        // 어쩌다가 최소 모집 인원보다 작은 숫자가 입력됐으면 강제로 2로 설정
        if totalGatheringPeople < ValidationError.Restrictions.minimumGatheringPeople {
            totalGatheringPeople = ValidationError.Restrictions.minimumGatheringPeople
        }
        
        return UpdatePostRequestDTO(
            title: title,
            detail: detail,
            imageUIDs: imageUids,
            totalGatheringPeople: totalGatheringPeople,
            currentlyGatheredPeople: currentlyGatheredPeople,
            referenceUrl: referenceUrl,
            shippingFee: shippingFee,
            price: price
        )
    }
    
    // 모집 완료되어 있는 글을 다시 모집 중으로 전환할 때를 위한 DTO 구성
    static func configureDTOForMarkingPostAsRegathering(
        title: String,
        detail: String,
        imageUIDs: [String]?,
        totalGatheringPeople: Int,
        currentlyGatheredPeople: Int,
        referenceUrl: String?,
        shippingFee: Int?,
        price: Int?
    ) -> UpdatePostRequestDTO {
        
        return UpdatePostRequestDTO(
            title: title,
            detail: detail,
            imageUIDs: imageUIDs,
            totalGatheringPeople: totalGatheringPeople,
            currentlyGatheredPeople: currentlyGatheredPeople,
            isCompletelyDone: false,                    // 모집 해제이니까 이 파라미터가 들어가야함
            referenceUrl: referenceUrl,
            shippingFee: shippingFee, price: price ?? 0
        )
    }
}
