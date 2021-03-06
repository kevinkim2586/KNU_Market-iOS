import Foundation
import Alamofire
import SwiftyJSON
import ProgressHUD

class ReportManager {
    
    //MARK: - Singleton
    static let shared: ReportManager = ReportManager()
    
    //MARK: - API Request URLs
    let reportUserURL               = "\(K.API_BASE_URL)report"
    
    let interceptor = Interceptor()
    
    //MARK: - 사용자 신고
    func reportUser(
        with model: ReportUserRequestDTO,
        completion: @escaping ((Result<Bool, NetworkError>) -> Void)
    ) {
        
        let url = reportUserURL + "/\(model.postUID)"
        
        AF.request(
            url,
            method: .post,
            parameters: model.parameters,
            encoding: JSONEncoding.default,
            interceptor: interceptor
        )
            .validate()
            .responseJSON { response in
                guard let statusCode = response.response?.statusCode else { return }
                switch statusCode {
                case 201:
                    completion(.success(true))
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("ReportManager - reportUser() failed with error: \(error.errorDescription)")
                    completion(.failure(error))
                    
                }
            }
    }
}
