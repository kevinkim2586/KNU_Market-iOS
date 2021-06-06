import Foundation
import Alamofire

struct UploadItemModel {
    
    let title: String
    let location: Int
    let peopleGathering: Int
    let imageData: Data?
    let detail: String
    
    let headers: HTTPHeaders = [
        
        HTTPHeaderKeys.authentication.rawValue: User.shared.accessToken
    ]
    
    
    
    
    
    
    
    
}
