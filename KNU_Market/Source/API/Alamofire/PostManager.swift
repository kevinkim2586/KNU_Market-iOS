import Foundation
import Alamofire

class PostManager {
    
    //MARK: - Singleton
    static let shared: PostManager = PostManager()
    
    let interceptor = Interceptor()
    
    //MARK: - API Request URLs
    let baseURL                       = "\(K.API_BASE_URL)posts"
    let searchURL                     = "\(K.API_BASE_URL)search"
    let markCompleteURL               = "\(K.API_BASE_URL)posts/complete/"
    
    
    //MARK: - 공구글 목록 불러오기
    func fetchPostList(
        at index: Int,
        fetchCurrentUsers: Bool = false,
        postFilterOption: PostFilterOptions,
        completion: @escaping ((Result<[PostListModel], NetworkError>) -> Void)
    ) {
        
        
        let url = fetchCurrentUsers == true
        ? baseURL + "/me?page=\(index)"
        : baseURL + "?page=\(index)"
        
        var headers: HTTPHeaders = [:]
        
        if postFilterOption == .showGatheringFirst {
            headers.update(name: "withoutcomplete", value: "1")
        }
        
        AF.request(url,
                   method: .get,
                   headers: headers,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                
                switch statusCode {
                    
                case 200:
                    do {
                        let decodedData = try JSONDecoder().decode([PostListModel].self,
                                                                   from: response.data ?? Data())
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ postManager - There was an error decoding JSON Data with error: \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("postManager fetchItemList error: \(error.errorDescription) and statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
//    //MARK: - 공구글 업로드
//    func uploadNewPost(
//        with model: UploadPostRequestDTO,
//        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
//    ) {
//        
//        AF.request(baseURL,
//                   method: .post,
//                   parameters: model.parameters,
//                   encoding: JSONEncoding.default,
//                   interceptor: interceptor)
//            .validate()
//            .responseJSON { response in
//                
//                guard let statusCode = response.response?.statusCode else { return }
//                
//                switch statusCode {
//                    
//                case 201:
//                    print("postManager - uploadNewItem success")
//                    completion(.success(true))
//                    
//                default:
//                    let error = NetworkError.returnError(json: response.data ?? Data())
//                    print("❗️ postManager - uploadNewItem failed with error: \(error.errorDescription)")
//                    completion(.failure(error))
//                }
//            }
//    }
    
    //MARK: - 공구글 수정
    func updatePost(
        uid: String,
        with model: UpdatePostRequestDTO,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        
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
                    print("✏️ postManager - editPost SUCCESS")
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ postManager - editPost FAILED with statusCode: \(statusCode) and reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 특정 공구글 불러오기
    func fetchPostDetails(
        uid: String,
        completion: @escaping ((Result<PostDetailModel, NetworkError>) -> Void)
    ) {
        
        let url = baseURL + "/\(uid)"
        
        AF.request(url,
                   method: .get,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 200:
                    do {
                        let decodedData = try JSONDecoder().decode(PostDetailModel.self,
                                                                   from: response.data ?? Data())
                        completion(.success(decodedData))
                        
                    } catch {
                        print("postManager - There was an error decoding JSON Data with error: \(error)")
                        completion(.failure(.E000))
                    }
                    
                default:
                    
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 본인 작성 게시글 삭제하기
    func deletePost(
        uid: String,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        let url = baseURL + "/\(uid)"
        
        AF.request(url,
                   method: .delete,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 201:
                    print("postManager - SUCCESS in deletePost")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ postManager deletePost error: \(error.errorDescription) and statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 검색 결과 불러오기
    func fetchSearchResults(
        at index: Int,
        keyword: String,
        completion: @escaping ((Result<[PostListModel], NetworkError>) -> Void)
    ) {
        
        var parameters: Parameters = [:]
        parameters["keyword"] = keyword
        parameters["page"] = index
        
        AF.request(
            searchURL,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.queryString
        )
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 200:
                    do {
                        let decodedData = try JSONDecoder().decode([PostListModel].self,
                                                                   from: response.data ?? Data())
                        completion(.success(decodedData))
                    } catch {
                        print("postManager - There was an error decoding JSON Data with error: \(error)")
                        completion(.failure(.E000))
                    }
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ postManager - fetchSearchResults error: \(error.errorDescription) with statusCode: \(statusCode)")
                    completion(.failure(error))
                }
            }
    }
    
    //MARK: - 공구글 완료 표시
    func markPostDone(
        uid: String,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        let url = markCompleteURL + uid
        
        AF.request(
            url,
            method: .put,
            interceptor: interceptor
        )
            .validate()
            .responseData { response in
                
                switch response.result {
                case .success:
                    print("✏️ postManager - markPostDone SUCCESS")
                    completion(.success(true))
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ postManager - markPostDone FAILED with error: \(error.errorDescription) and statusCode: \(String(describing: response.response?.statusCode))")
                    completion(.failure(error))
                    
                }
            }
    }
}

