import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    typealias UserId = String
    
    //MARK: - 아이디 찾기
    func findUserId(
        using option: FindIdOption,
        studentEmail: String? = nil,
        studentId: String? = nil,
        studentBirthDate: String? = nil,
        completion: @escaping (Result<UserId, NetworkError>) -> Void
    ) {
        let parameters: Parameters
        
        switch option {
        case .webMail:
            guard let studentEmail = studentEmail else {
                completion(.failure(.E000))
                return
            }
            parameters = ["studentEmail": studentEmail]
        case .studentId:
            guard let studentId = studentId, let studentBirthDate = studentBirthDate else {
                completion(.failure(.E000))
                return
            }
            parameters = ["studentId": studentId, "studentBirth": studentBirthDate]
        }
    
        AF.request(
            findIdURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        ).responseJSON { response in
            
            switch response.result {
            case .success(_):
                print("✏️ UserManager - findUserId SUCCESS")
                do {
                    let json = try JSON(data: response.data ?? Data())
                    let foundId = json["id"].stringValue
                    completion(.success(foundId))
                } catch {
                    completion(.failure(.E000))
                }
            case .failure(_):
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ UserManager - findUserID FAILED with statusCode: \(String(describing: response.response?.statusCode)) and reason: \(error.errorDescription)")
                completion(.failure(error))
                
            }
        }
        
        
    }
    
    
    
    
    //MARK: - 비밀번호 찾기
    func findPassword(
        email: String,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        
        let parameters: Parameters = [ "id" : email ]
        
        AF.request(findPasswordURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default)
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                
                case 201:
                    print("✏️ UserManager - findPassword SUCCESS")
                    completion(.success(true))
                    
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ UserManager findPassword error statusCode: \(statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
}
