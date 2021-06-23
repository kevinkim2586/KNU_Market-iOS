import Foundation
import Alamofire
import SwiftyJSON


final class Interceptor: RequestInterceptor {
    
    private var isRefreshing: Bool = false
    private var retryLimit = 3
    
    // 어떠한 AF request 이든지간데 중간에 가로채서 header 에 accesstoken 을 넣는 것이기에 매번 넣을 필요 X
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        print("Interceptor - adapt() activated")
        
        var request = urlRequest
        
        request.headers.update(name: "authentication", value: User.shared.accessToken)
        
        completion(.success(request))
    }
    
    
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        
        guard let statusCode = request.response?.statusCode else {
            completion(.doNotRetry)
            return
        }
        
        print("Interceptor - adapt() activated with statusCode: \(statusCode)")
        
        switch statusCode {
        
        case 200...299:
            completion(.doNotRetry)

        case 412:
            guard !isRefreshing else { return }
            
            refreshToken() { [weak self] refreshResult in
                
                guard let self = self else { return }
                
                switch refreshResult {
                
                case .success(_):
                    
                    if request.retryCount < self.retryLimit {
                        completion(.retry)
                    } else {
                        completion(.doNotRetry)
                    }
                  
                case .failure(let error):
                    
                    if error == .E301 {
                        print("Interceptor - 세션이 만료되었습니다. 다시 로그인 요망")
                    }
                    else {
                        print("Interceptor - 이건 뭔 에러지?")
                        completion(.doNotRetry)
                    }
                    
                }
            }
        default:
            if request.retryCount > 5 {
                print("Interceptor retry() error: \(error)")
                completion(.doNotRetry)
            }
            completion(.doNotRetry)
        
        }
    }
    
}

extension Interceptor {
    
    typealias RefreshCompletion = (_ completion: Result<Bool, NetworkError>) -> Void
    
    func refreshToken(completion: @escaping RefreshCompletion) {
        
        print("Interceptor - refreshToken() activated")
        
        self.isRefreshing = true
        
        let headers: HTTPHeaders = [
            "authentication" : User.shared.accessToken,
            "refreshToken" : User.shared.refreshToken
        ]
        
        AF.request(UserManager.shared.requestAccessTokenURL,
                   method: .get,
                   headers: headers).responseJSON { [weak self] response in
                    
                    self?.isRefreshing = false
                    
                    guard let statusCode = response.response?.statusCode else { return }
                    
                    print("Interceptor - refreshToken() activated with statusCode: \(statusCode)")
                    
                    switch statusCode {
                    
                    case 201:
                        
                        do {
                            
                            let json = try JSON(data: response.data!)
                            UserManager.shared.saveRefreshedAccessToken(from: json)
                            print("successfully refreshed NEW token: \(User.shared.accessToken)")
                            completion(.success(true))
                            
                        } catch {
                            
                        }
                        
                    default:
                        print("Interceptor - refreshToken() failed default")
                        let error = NetworkError.returnError(json: response.data!)
                        completion(.failure(error))
                    
                    }
                   }
    }
}
