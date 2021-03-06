import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    //MARK: - 학생증 인증
    func uploadStudentIdVerificationInformation(
        with model: StudentIdVerificationDTO,
        completion: @escaping (Result<Bool, NetworkError>) -> Void
    ) {
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(
                    Data(model.studentId.utf8),
                    withName: "studentId"
                )
                multipartFormData.append(
                    Data(model.studentBirth.utf8),
                    withName: "studentBirth"
                )
                
                multipartFormData.append(
                    model.studentIdImageData,
                    withName: "media",
                    fileName: "studentId.jpeg",
                    mimeType: "image/jpeg"
                )
            },
            to: studentIdVerifyURL,
            interceptor: interceptor
        ).responseJSON { response in
            
            switch response.result {
            case .success(_):
                print("✏️ UserManager - uploadStudentIdVerificationInformation SUCCESS")
                User.shared.isVerified = true
                completion(.success(true))
            case .failure(_):
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ UserManager - uploadStudentIdVerificationInformation error: \(error.errorDescription) with statusCode: \(String(describing: response.response?.statusCode))")
                completion(.failure(error))
            }
        }
        
    }
    
    //MARK: - 인증 메일 보내기 (@knu.ac.kr로 보내기)
    func sendVerificationEmail(
        email: String,
        completion: @escaping (Result<Bool, NetworkError>
        ) -> Void) {
        
        let parameters: Parameters = ["studentEmail": email]
        
        AF.request(
            sendEmailURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            interceptor: interceptor
        ).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
                
            case 201:
                print("✏️ UserManager - sendVerificationEmail SUCCESS")
                User.shared.isVerified = true
                completion(.success(true))
                
            default:
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ UserManager - sendVerificationEmail statusCode: \(statusCode), reason: \(error.errorDescription)")
                completion(.failure(error))
            }
        }
    }
}
