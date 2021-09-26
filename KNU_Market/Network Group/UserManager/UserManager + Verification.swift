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
                    withName: "studentId"
                )
                
                multipartFormData.append(
                    model.studentIdImageData,
                    withName: "media",
                    fileName: "studentId.jpeg",
                    mimeType: "image/jpeg"
                )
            },
            to: studentIdVerifyURL,
            headers: model.headers,
            interceptor: interceptor
        ).responseJSON { response in
            
            switch response.result {
            case .success(_):
                print("✏️ UserManager - uploadStudentIdVerificationInformation SUCCESS")
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
        
        let headers: HTTPHeaders = ["id" : email]
        
        AF.request(
            sendEmailURL,
            method: .post,
            headers: headers
        ).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
                
            case 201:
                print("✏️ UserManager - resendVerificationEmail SUCCESS")
                completion(.success(true))
                
            default:
                let error = NetworkError.returnError(json: response.data ?? Data())
                print("❗️ UserManager - resendVerificationEmail statusCode: \(statusCode), reason: \(error.errorDescription)")
                completion(.failure(error))
            }
        }
    }
}
