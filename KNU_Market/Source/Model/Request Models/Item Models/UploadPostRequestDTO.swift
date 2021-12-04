import Foundation
import Alamofire

struct UploadPostRequestDTO {
    
    let title: String
    let location: Int
    let peopleGathering: Int
    let imageUIDs: [String]?
    let detail: String

    var parameters: Parameters = [:]
    
    init(title: String, location: Int, peopleGathering: Int, imageUIDs: [String]?, detail: String) {
        
        self.title = title
        self.location = location
        self.peopleGathering = peopleGathering
        self.detail = detail
        
        parameters["title"] = self.title
        parameters["spotCategory"] = self.location
        parameters["recruitment"] = self.peopleGathering
        parameters["content"] = self.detail
        
        if let imageUIDs = imageUIDs {
            
            self.imageUIDs = imageUIDs
            parameters["image"] = self.imageUIDs
            
        } else {
            self.imageUIDs = nil
        }
    }

}
