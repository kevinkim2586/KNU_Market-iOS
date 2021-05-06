import Foundation
import UIKit

protocol UploadItemDelegate {
    func didCompleteUpload(_ success: Bool)
}

class UploadItemViewModel {
    
    //MARK: - Object Properties
    var delegate: UploadItemDelegate?
    
    var itemTitle: String
    
    var location: String
    
    var peopleGathering: Int
    
    var itemExplanation: String
    
    var userSelectedImages: [UIImage] {
        didSet { convertUIImagesToDataFormat() }
    }
    
    var userSelectedImagesInDataFormat: [Data]?
    
    
    //MARK: - Initialization
    
    init() {
        
        self.itemTitle = ""
        self.location = ""
        self.peopleGathering = 0
        self.itemExplanation = ""
        self.userSelectedImages = [UIImage]()
    
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
