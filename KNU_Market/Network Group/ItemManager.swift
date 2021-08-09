import Foundation
import Alamofire

class ItemManager {
    
    //MARK: - Singleton
    static let shared: ItemManager = ItemManager()
    
    let interceptor = Interceptor()
    
    private init() {}
    
    //MARK: - API Request URLs
    let baseURL                       = "\(Constants.API_BASE_URL)posts"
    let searchURL                     = "\(Constants.API_BASE_URL)search"
    let markCompleteURL               = "\(Constants.API_BASE_URL)posts/complete/"

    
    //MARK: - 공구글 목록 불러오기
    func fetchItemList(at index: Int,
                       fetchCurrentUsers: Bool = false,
                       completion: @escaping ((Result<[ItemListModel], NetworkError>) -> Void)) {
        
        
        let url = fetchCurrentUsers == true
            ? baseURL + "/me?page=\(index)"
            : baseURL + "?page=\(index)"

        AF.request(url,
                   method: .get,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 200:
                    
                    print("ItemManager - SUCCESS in fetchItemList")
                    
                    do {
                        let decodedData = try JSONDecoder().decode([ItemListModel].self,
                                                                   from: response.data!)
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ ItemManager - There was an error decoding JSON Data with error: \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("ItemManager fetchItemList error: \(error.errorDescription) and statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 공구글 업로드
    func uploadNewItem(with model: UploadItemRequestDTO,
                       completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        AF.request(baseURL,
                   method: .post,
                   parameters: model.parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("ItemManager - uploadNewItem success")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ItemManager - uploadNewItem failed with error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 공구글 수정
    func updatePost(uid: String,
                  with model: UpdatePostRequestDTO,
                  completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let url = baseURL + "/\(uid)"
        
        AF.request(url,
                   method: .put,
                   parameters: model.parameters,
                   encoding: JSONEncoding.default,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("✏️ ItemManager - editPost SUCCESS")
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ItemManager - editPost FAILED with statusCode: \(statusCode) and reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 특정 공구글 불러오기
    func fetchItemDetails(uid: String,
                          completion: @escaping ((Result<ItemDetailModel, NetworkError>) -> Void)) {
        
        let url = baseURL + "/\(uid)"
        
        AF.request(url,
                   method: .get,
                   interceptor: interceptor)
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
    
    //MARK: - 본인 작성 게시글 삭제하기
    func deletePost(uid: String,
                    completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let url = baseURL + "/\(uid)"
        
        AF.request(url,
                   method: .delete,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("ItemManager - SUCCESS in deletePost")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ItemManager deletePost error: \(error.errorDescription) and statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 검색 결과 불러오기
    func fetchSearchResults(at index: Int,
                            keyword: String,
                            completion: @escaping ((Result<[ItemListModel], NetworkError>) -> Void)) {
        
        var parameters: Parameters = [:]
        parameters["keyword"] = keyword
        parameters["page"] = index
        
        AF.request(searchURL,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.queryString)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 200:
                    
                    print("✏️ ItemManager - fetchSearchResults SUCCESS")
                    
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
                    print("❗️ ItemManager - fetchSearchResults error: \(error.errorDescription) with statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
    
    //MARK: - 공구글 완료 표시
    func markPostDone(uid: String,
                      completion: @escaping ((Result<Bool, NetworkError>) -> Void)) {
        
        let url = markCompleteURL + uid
        
        AF.request(url,
                   method: .put,
                   interceptor: interceptor)
            .validate()
            .responseData { response in
                
                switch response.result {
                
                case .success:
                    
                    print("✏️ ItemManager - markPostDone SUCCESS")
                    completion(.success(true))
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ItemManager - markPostDone FAILED with error: \(error.errorDescription) and statusCode: \(String(describing: response.response?.statusCode))")
                    completion(.failure(error))
                    
                }
            }
    }
}
    
