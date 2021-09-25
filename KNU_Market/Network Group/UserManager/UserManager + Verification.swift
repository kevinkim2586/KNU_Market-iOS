import Foundation
import Alamofire
import SwiftyJSON

extension UserManager {
    
    // 학생증 인증
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
    
}
