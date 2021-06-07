import Foundation
import Alamofire

class ItemManager {
    
    //MARK: - Singleton
    static let shared: ItemManager = ItemManager()
    
    private init() {}
    
    //MARK: - API Request URLs
    let writePostURL                 = "\(Constants.API_BASE_URL)posts"
    

    //MARK: - 공구글 업로드
    
    //multipart이 아니라 json으로
    func uploadNewItem(with model: UploadItemModel,
                       completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(writePostURL,
                   method: .post,
                   parameters: model.parameters,
                   encoding: JSONEncoding.default,
                   headers: model.headers).responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    
                    case 201:
                        print("ItemManager - uploadNewItem success")
                        completion(.success(true))
                        
                    default:
                        let error = NetworkError.returnError(json: response.data!)
                        print("ItemManager - uploadNewItem failed with error: \(error.errorDescription)")
                        completion(.failure(error))
                    }
                   }
        
    }
    
    
    
}
