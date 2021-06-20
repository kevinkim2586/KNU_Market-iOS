import Foundation
import Alamofire

class ItemManager {
    
    //MARK: - Singleton
    static let shared: ItemManager = ItemManager()
    
    let interceptor = Interceptor()
    
    private init() {}
    
    //MARK: - API Request URLs
    let writePostURL                 = "\(Constants.API_BASE_URL)posts"
    let getPostsURL                  = "\(Constants.API_BASE_URL)posts"
    
    
    
    //MARK: - 공구글 목록 불러오기
    func fetchItemList(completion: @escaping ((Result<[ItemListModel], NetworkError>) -> Void)) {
        
        AF.request(getPostsURL,
                   method: .get,
                   interceptor: interceptor)
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 200:
                    
                    print("ItemManager - SUCCESS in getItemList")
                    
                    do {
                        let decodedData = try JSONDecoder().decode([ItemListModel].self,
                                                                   from: response.data!)
                        completion(.success(decodedData))
    
                    } catch {
                        print("ItemManager - There was an error decoding JSON Data with error: \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("ItemManager getItemList error: \(error.errorDescription) and statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
                                            
                                

    //MARK: - 공구글 업로드
    func uploadNewItem(with model: UploadItemModel,
                       completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(writePostURL,
                   method: .post,
                   parameters: model.parameters,
                   encoding: JSONEncoding.default,
                   headers: model.headers)
            .responseJSON { response in
                    
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
    
    //MARK: - 특정 공구글 불러오기
    func fetchItemDetails(uid: String,
                          completion: @escaping ((Result<ItemDetailModel, NetworkError>) -> Void)) {
        
        let url = getPostsURL + "/\(uid)"
        
        AF.request(url,
                   method: .get)
            .validate()
            .responseJSON { response in
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    switch statusCode {
                    
                    case 200:
                       
                        print("ItemManager - SUCCESS in fetchItemList")
                        
                        do {
                            let decodedData = try JSONDecoder().decode(ItemDetailModel.self,
                                                                       from: response.data!)
                            completion(.success(decodedData))
                            
                        } catch {
                            print("ItemManager - There was an error decoding JSON Data with error: \(error)")
                            completion(.failure(.E000))
                        }
                        
                    default:
                        
                        let error = NetworkError.returnError(json: response.data!)
                        print("ItemManager fetchItemList error: \(error.errorDescription) and statusCode: \(statusCode)")
                        completion(.failure(error))
                    }
                   }
    }
    
    
}
