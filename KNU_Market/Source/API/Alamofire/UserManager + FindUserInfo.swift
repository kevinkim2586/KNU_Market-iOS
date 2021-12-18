import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    typealias UserId = String
    
    //MARK: - 아이디 찾기
    func findUserId(
        using option: FindUserInfoOption,
        studentEmail: String? = nil,
        studentId: String? = nil,
        studentBirthDate: String? = nil,
        completion: @escaping (Result<UserId, NetworkError>) -> Void
    ) {
        var parameters: Parameters = [:]
        
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
        default: completion(.failure(.E000))
        }
        
        AF.request(
            findIdURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success(_):
                    do {
                        let json = try JSON(data: response.data ?? Data())
                        let foundId = json["id"].stringValue
                        print("✏️ foundId: \(foundId)")
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
        id: String,
        completion: @escaping (Result<String, NetworkError>) -> Void
    ) {
        
        let parameters: Parameters = ["id" : id]
        
        AF.request(
            findPasswordURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
        )
            .responseJSON { response in
                
                guard let statusCode = response.response?.statusCode else { return }
                
                switch statusCode {
                    
                case 201:
                    print("✏️ UserManager - findPassword SUCCESS")
                    do {
                        let json = try JSON(data: response.data ?? Data())
                        let emailPasswordSent = json["email"].stringValue
                        completion(.success(emailPasswordSent))
                    } catch {
                        completion(.failure(.E000))
                    }
                default:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ UserManager findPassword error statusCode: \(statusCode) and error: \(error.errorDescription)")
                    completion(.failure(error))
                }
            }
    }
}
