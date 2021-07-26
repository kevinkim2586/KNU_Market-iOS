import Foundation
import UIKit

protocol UploadItemDelegate: AnyObject {
    func didCompleteUpload()
    func failedUploading(with error: NetworkError)
}

class UploadItemViewModel {
    
    //MARK: - Object Properties
    weak var delegate: UploadItemDelegate?
    
    var itemTitle: String = ""
    
    var location: Int = 0
    let locationArray: [String] = Location.list

    var peopleGathering: Int = 2
    
    var itemDetail: String = ""
    
    var userSelectedImages: [UIImage] = [] {
        didSet { convertUIImagesToDataFormat() }
    }
    
    var userSelectedImagesInDataFormat: [Data]?
    
    lazy var imageUIDs: [String] = []
    
    //MARK: - Initialization
    
    init() {
    
    }
    
    
    //MARK: - API
    func uploadImageToServerFirst() {
        
        guard let imageData = userSelectedImagesInDataFormat else {
            self.delegate?.failedUploading(with: .E000)
            return
        }
        
        let group = DispatchGroup()
        
        for image in imageData {
            
            group.enter()
            MediaManager.shared.uploadImage(with: image) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                
                case .success(let uid):
                    print("UploadItemVM: success in uploading image with uid: \(uid)")
                    self.imageUIDs.append(uid)
                case .failure(let error):
                    print("UploadItemVM: failed uploading image with error: \(error.errorDescription)")
                    self.delegate?.failedUploading(with: error)
                }
                print("group.leave() called")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✏️ Dispatch Group has ended.")
            self.uploadItem()
        }
        
    }
    
    func uploadItem() {
        
        let model = UploadItemRequestDTO(title: itemTitle,
                                    location: location,
                                    peopleGathering: peopleGathering,
                                    imageUIDs: imageUIDs,
                                    detail: itemDetail)
        
        ItemManager.shared.uploadNewItem(with: model) { [weak self] result in
            
            guard let self = self else { return }
            
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
