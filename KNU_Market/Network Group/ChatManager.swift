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
    
    private init() {}
    
    //MARK: - API Request URLs
    let baseURL     = "\(Constants.API_BASE_URL)room/"
    
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
            .responseData { response in
                
                switch response.result {
                
                case .success:
                    print("✏️ ChatManager - changeJoinStatus SUCCESS")
                    completion(.success(true))
                case .failure:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ChatManager - changeJoinStatus error with code: \(response.response!.statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                    
                    
                }
            }
    }
    
    func getResponseModel<T: Decodable>(function: ChatFunction,
                                        method: HTTPMethod,
                                        pid: String?,
                                        index: Int?,
                                        expectedModel: T.Type,
                                        completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let requestURL = generateURLString(for: function, pid: pid, index: index)
        
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
                        print("✏️ ChatManager - getResponse SUCCESS for function: \(function)")
                        completion(.success(decodedData))
                        
                    } catch {
                        print("❗️ ChatManager - getResponse decoding error: \(error) for function: \(function)")
                        
                        completion(.failure(.E000))
                    }
                    
                case .failure:
                    let error = NetworkError.returnError(json: response.data!)
                    print("❗️ ChatManager - getResponse ERROR with code: \(response.response!.statusCode) and error: \(error.errorDescription)")
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
