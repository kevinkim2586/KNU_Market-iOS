import Foundation
import Alamofire

struct UpdatePostRequestDTO {
    
    var parameters: Parameters = [:]
    
    init(title: String, location: Int, detail: String, imageUIDs: [String], totalGatheringPeople: Int, currentlyGatheredPeople: Int, isCompletelyDone: Bool? = nil) {
        
        parameters["title"] = title
        parameters["spotCategory"] = location
        parameters["content"] = detail
        parameters["maxHeadcount"] = totalGatheringPeople
        parameters["currentHeadcount"] = currentlyGatheredPeople
        parameters["image"] = imageUIDs
        
        if isCompletelyDone != nil {
            parameters["isArchived"] = isCompletelyDone
        }
    }
}
