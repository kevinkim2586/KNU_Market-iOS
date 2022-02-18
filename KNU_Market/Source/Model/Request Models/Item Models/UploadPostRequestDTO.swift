import Foundation
import Alamofire

struct UploadPostRequestDTO {

    let title: String
    let content: String
    let location: Int = Location.list.count      // v1.3까지는 default 8 == 협의
    let headCount: Int
    let price: Int
    let shippingFee: Int
    let referenceUrl: String?
    let images: [Data]?
    
    init(
        title: String,
        content: String,
        headCount: Int,
        price: Int,
        shippingFee: Int,
        referenceUrl: String?,
        images: [Data]?
    ) {
        self.title = title
        self.content = content
        self.headCount = headCount
        self.price = price
        self.shippingFee = shippingFee
        self.referenceUrl = referenceUrl ?? nil
        self.images = images ?? nil
    }

    static func configureDTO(
        title: String?,
        price: String?,
        shippingFee: String?,
        totalGatheringPeople: String?,
        detail: String?,
        referenceUrl: String?,
        imageDatas: [Data]?
    ) -> UploadPostRequestDTO? {
            
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
                content: detail,
                headCount: peopleGathering,
                price: price,
                shippingFee: shippingFee,
                referenceUrl: referenceUrl,
                images: imageDatas
            )
        }
}
