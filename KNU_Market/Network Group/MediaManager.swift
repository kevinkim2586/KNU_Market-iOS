import Foundation
import Alamofire
import SwiftyJSON

class MediaManager {
    
    static let shared: MediaManager = MediaManager()
    
    private init() {}
    
    let uploadImageURL              = "\(Constants.API_BASE_URL)media"
    let requestMediaURL             = "\(Constants.API_BASE_URL)media/"
    
    //MARK: - 파일 조회
    func requestMedia(from urlString: String,
                      completion: @escaping ((Result<Data?, NetworkError>) -> Void)) {
        
        let requestURL = requestMediaURL + urlString
        
        AF.request(requestURL,
                   method: .get).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    case 200:
                        completion(.success(response.data!))
                    default:
                        print("requestMedia FAILED")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    }
                   }
    }
    
    //MARK: - 이미지 업로드
    func uploadImage(with images: Data,
                     completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        
        let headers: HTTPHeaders = [ HTTPHeaderKeys.authentication.rawValue : User.shared.accessToken ]
        
        AF.upload(multipartFormData: { multipartFormData in
            
            
            multipartFormData.append(images,
                                     withName: "media",
                                     fileName: "\(UUID().uuidString).jpeg",
                                     mimeType: "image/jpeg")
            
            
        }, to: uploadImageURL,
        headers: headers).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 201:
                do {
                    
                    let json = try JSON(data: response.data!)
                    let imageID = json["uid"].stringValue
                    print("UserManager: newly updated profileImage UID: \(imageID)")
                    completion(.success(imageID))
                    
                } catch {
                    print("UserManager - uploadImage() catch error \(error)")
                    let error = NetworkError.returnError(json: response.data!)
                    completion(.failure(error))
                }
            default: completion(.failure(.E000))
            }
        }
    }
    
    
}
