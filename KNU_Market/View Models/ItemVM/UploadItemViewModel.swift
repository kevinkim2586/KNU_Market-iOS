import Foundation
import UIKit

protocol UploadItemDelegate {
    func didCompleteUpload(_ success: Bool)
}

class UploadItemViewModel {
    
    //MARK: - Object Properties
    var delegate: UploadItemDelegate?
    
    var itemTitle: String = ""
    
    var location: String = ""
    
    let locationArray: [String] = [
        "북문",
        "동문",
        "테크노문",
        "쪽문",
        "정문",
        "서문",
        "기숙사 (아래에 명시)",
        "협의 (아래에 명시)"
    ]
    
    var peopleGathering: Int = 2
    
    var itemDetail: String = ""
    
    var userSelectedImages: [UIImage] = [] {
        didSet { convertUIImagesToDataFormat() }
    }
    
    var userSelectedImagesInDataFormat: [Data]?
    
    
    //MARK: - Initialization
    
    init() {
    
    }
    
    //MARK: - User Input Validation
    
    func validateUserInputs() throws {
        
    }
    
    //MARK: - Conversion Methods
    
    func convertUIImagesToDataFormat() {
        
        userSelectedImagesInDataFormat?.removeAll()
        
        userSelectedImagesInDataFormat = userSelectedImages.map( { (image: UIImage) -> Data in
            
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                return imageData
            } else {
                print("Unable to convert UIImage to Data type")
                return Data()
            }
        })
    }
    
}
