import Foundation
import Alamofire

class ChatManager {
    
    static let shared: ChatManager = ChatManager()
    
    let interceptor = Interceptor()
    
    private init() {}
    
    //MARK: - API Request URLs
    let baseURL     = "\(Constants.API_BASE_URL)room/"
    
    //MARK: - 공구 참여하기
    func joinPost(pid: String,
                  completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let requestURL = baseURL + pid
        
        AF.request(requestURL,
                   method: .post,
                   interceptor: interceptor)
            .validate()
            .responseData { response in
                
                switch response.result {
                
                case .success:
                    print("✏️ ChatManager - joinPost SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ChatManager - joinPost error with code: \(response.response!.statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                    
                    
                }
            }
    }
    
    
    func getResponse<T: Decodable>(method: HTTPMethod,
                                   pid: String?,
                                   expectedModel: T.Type,
                                   completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let requestURL = pid == nil ? baseURL : baseURL + pid!
        
        print("✏️ requestURL: \(requestURL)")
        
        AF.request(requestURL,
                   method: method,
                   interceptor: interceptor)
            .validate()
            .responseData { response in
                
                switch response.result {
                
                case .success:
                    
                    do {
                        let decodedData = try JSONDecoder().decode(expectedModel,
                                                                   from: response.data!)
                        print("✏️ ChatManager - getResponse SUCCESS")
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ ChatManager - getResponse catch error: \(error.localizedDescription)")
                        completion(.failure(.E000))
                    }
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ChatManager - getResponse ERROR with code: \(response.response!.statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
        }
        
        
        
        
    }
    
    
//    func getResponse(url: String,
//                     method: HTTPMethod) {
//
//        AF.request(url,
//                   method: method,
//                   interceptor: interceptor)
//            .validate()
//            .responseData { response in
//
//                switch response.result {
//
//                case .success:
//
//                case .failure:
//                    let error = NetworkError.returnError(json: response.data!)
//                }
//
//
//
//            }
//    }
//
    
}


