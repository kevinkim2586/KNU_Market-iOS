import Foundation
import Alamofire
import SwiftyJSON

enum ChatFunction {
    case join
    case exit
    case getRoom
    case getRoomInfo
    case getChat
}

class ChatManager {
    
    static let shared: ChatManager = ChatManager()
    
    let interceptor = Interceptor()
    
    //MARK: - API Request URLs
    let baseURL     = "\(K.API_BASE_URL)room/"
    
    //MARK: - 공구 참여 or 나가기
    func changeJoinStatus(function: ChatFunction,
                          pid: String,
                          completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let requestURL = generateURLString(for: function, pid: pid)
        let method: HTTPMethod = function == .join ? .post : .delete
        
        AF.request(requestURL,
                   method: method,
                   interceptor: interceptor)
            .validate()
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ ChatManager - changeJoinStatus error with code: \(response.response!.statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
                

            }
    }
    
    func getResponseModel<T: Decodable>(
        function: ChatFunction,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil,
        pid: String?,
        index: Int?,
        expectedModel: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        
        let requestURL = generateURLString(for: function, pid: pid, index: index)
        
        AF.request(
            requestURL,
            method: method,
            headers: headers,
            interceptor: interceptor
        )
            .validate()
            .responseData { response in
                
                switch response.result {
                case .success:
                    do {
                        let decodedData = try JSONDecoder().decode(expectedModel,
                                                                   from: response.data ?? Data())
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ ChatManager - getResponse decoding error: \(error) for function: \(function)")
                        completion(.failure(.E000))
                    }
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ ChatManager - getResponse ERROR with code: \(response.response?.statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
    
    func banUser(userUID: String,
                 in room: String,
                 completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        let url = baseURL + room + "/\(userUID)"
        
        print("✏️ banUser url: \(url)")
        
        AF.request(url,
                   method: .delete,
                   interceptor: interceptor)
            .validate()
            .responseData { response in
                
                switch response.result {
                    
                case .success:
                    print("✏️ ChatManager - banUser SUCCESS")
                    completion(.success(true))
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ ChatManager - banUser ERROR with code: \(response.response!.statusCode) and reason: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }

}



//MARK: - Utility Method

extension ChatManager {
    
    // 채팅 API 요청 시 필요한 URL 생성 함수
    func generateURLString(for function: ChatFunction, pid: String?, index: Int? = nil) -> String {
        
        switch function {
        
        case .join, .exit, .getRoomInfo:
            guard let pid = pid else { fatalError() }
            return baseURL + pid
        case .getRoom:
            return baseURL
        case .getChat:
            guard let page = index, let pid = pid else { fatalError() }
            return baseURL + pid + "/" + String(page)
        }
    }
}
