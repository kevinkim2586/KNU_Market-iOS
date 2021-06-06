import Foundation
import UIKit

protocol UploadItemDelegate {
    func didCompleteUpload(_ success: Bool)
    func failedUploading(with error: NetworkError)
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
    
    
    //MARK: - API
    func uploadItem() {
        
        
        
        
    }
    
    
    
    
    
    //MARK: - User Input Validation
    
    func validateUserInputs() throws {
        
        guard itemTitle.count >= 3, itemTitle.count <= 30 else {
            throw UserInputError.titleTooShortOrLong
        }
        
        guard itemDetail.count >= 3, itemDetail.count <= 300 else {
            throw UserInputError.detailTooShortOrLong
        }
    }
    
    //MARK: - Conversion Methods
    
    func convertUIImagesToDataFormat() {
        
        userSelectedImagesInDataFormat?.removeAll()
        
        userSelectedImagesInDataFormat = userSelectedImages.map( { (image: UIImage) -> Data in
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                return imageData
            } else {
                print("Unable to convert UIImage to Data type")
                return Data()
            }
        })
    }
    
}
