import Foundation
import Alamofire

struct StudentIdVerificationDTO {
    
    let studentId: String
    let studentBirth: String
    let studentIdImageData: Data
    
    let headers: HTTPHeaders = ["id": User.shared.userID]
    
    init(studentId: String, studentBirth: String, studentIdImageData: Data) {
        self.studentId = studentId
        self.studentBirth = studentBirth
        self.studentIdImageData = studentIdImageData
    }

}
