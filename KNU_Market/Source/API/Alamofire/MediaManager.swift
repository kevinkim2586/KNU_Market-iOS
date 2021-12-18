import Foundation
import Alamofire
import SwiftyJSON

class MediaManager {
    
    static let shared: MediaManager = MediaManager()
    
    let interceptor = Interceptor()
    
    let uploadImageURL              = "\(K.API_BASE_URL)media"
    let requestMediaURL             = "\(K.API_BASE_URL)media/"
    let deleteMediaURL              = "\(K.API_BASE_URL)media/"
    
    var imageUIDs: [String] = [String]()
    
    //MARK: - 파일 조회
    func requestMedia(from imageUID: String,
                      completion: @escaping ((Result<Data?, NetworkError>) -> Void)) {
        
        let requestURL = requestMediaURL + imageUID
        
        AF.request(requestURL,
                   method: .get,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    case 200:
                        
                        if let fetchedData = response.data {
                            completion(.success(fetchedData))
                        } else {
                            completion(.success(nil))
                        }
                    default:
                        print("❗️ MediaManager -requestMedia FAILED ")
                        let error = NetworkError.returnError(json: response.data ?? Data())
                        completion(.failure(error))
                    }
                   }
    }
    
    //MARK: - 이미지 업로드
    func uploadImage(with image: Data,
                     completion: @escaping ((Result<String, NetworkError>) -> Void)) {
        
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(image,
                                     withName: "media",
                                     fileName: "newImage.jpeg",
                                     mimeType: "image/jpeg")
            
        }, to: uploadImageURL,
        interceptor: interceptor)
        .validate()
        .responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 201:
                do {
                    
                    let json = try JSON(data: response.data ?? Data())
                    let imageID = json["uid"].stringValue
                    print("MediaManager: newly uploaded image UID: \(imageID)")
                    completion(.success(imageID))
                    
                } catch {
                    print("MediaManager - uploadImage() catch error \(error)")
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            // 너무 큰 용량의 사진
            case 413:
                let error = NetworkError.E413
                completion(.failure(error))
                
            default:
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ MediaManager - uploadImage failed with statusCode: \(statusCode) and reason: \(error.errorDescription)")
                
                completion(.failure(error))
            }
        }
    }
    
    //MARK: - 이미지 삭제
    func deleteImage(uid: String,
                     completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let url = deleteMediaURL + uid
        
        AF.request(url,
                   method: .delete,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("✏️ MediaManager - deleteImage SUCCESS for uid: \(uid)")
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ MediaManager - deleteImage FAILED with statusCode: \(statusCode) and reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
}
