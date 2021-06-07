import Foundation
import UIKit

protocol UploadItemDelegate {
    func didCompleteUpload()
    func failedUploading(with error: NetworkError)
}

class UploadItemViewModel {
    
    //MARK: - Object Properties
    var delegate: UploadItemDelegate?
    
    var itemTitle: String = ""
    
    var location: Int = 0
    let locationArray: [String] = Location.list

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
    
    
    func uploadImageToServerFirst() {
        
        guard let imageData = userSelectedImagesInDataFormat else {
            self.delegate?.failedUploading(with: .E000)
            return
        }
        
        MediaManager.shared.uploadImage(with: imageData) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let uid):
                
            case .failure(let error):
                
            }
            
            
            
        }
        
    }
    
    
    
    
    
    
    
    func uploadItem() {
        
        let model = UploadItemModel(title: itemTitle,
                                    location: location,
                                    peopleGathering: peopleGathering,
                                    imageUIDs: nil,
                                    detail: itemDetail)
        
        ItemManager.shared.uploadNewItem(with: model) { result in
            
            switch result {
            
            case .success(_):
                
                self.delegate?.didCompleteUpload()
                
            case .failure(let error):
                
                print("UploadItemViewModel - uploadItem() failed: \(error.errorDescription)")
                self.delegate?.failedUploading(with: error)
            }
        }
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
