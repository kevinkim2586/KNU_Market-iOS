import Foundation
import Alamofire

struct StudentIdVerificationDTO {
    
    let studentId: String
    let studentBirth: String
    let media: Data
    
    let headers: HTTPHeaders = ["id": User.shared.userID]
    
    init(studentId: String, studentBirth: String, media: Data) {
        self.studentId = studentId
        self.studentBirth = studentBirth
        self.media = media
    }

}
