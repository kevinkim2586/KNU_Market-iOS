import Foundation
import UIKit

protocol UploadPostDelegate: AnyObject {
    func didCompleteUpload()
    func failedUploading(with error: NetworkError)
    
    func didUpdatePost()
    func failedUpdatingPost(with error: NetworkError)
}

class UploadPostViewModel {
    
    //MARK: - Properties
    
    private var mediaManager: MediaManager?
    private var postManager: PostManager?
    
    weak var delegate: UploadPostDelegate?
    
    var requiredMinimumPeopleToGather: Int = 2
    
    var postTitle: String = ""
    
    var location: Int = 0
    let locationArray: [String] = Location.list

    var totalPeopleGathering: Int = 2
    
    var postDetail: String = ""
    
    var userSelectedImages: [UIImage] = [] {
        didSet { convertUIImagesToDataFormat() }
    }
    
    var userSelectedImagesInDataFormat: [Data]?
    
    lazy var imageUIDs: [String] = []
    
    //MARK: - Properties for updating post
    var editPostModel: EditPostModel?
    
    lazy var priorImageURLs: [URL] = [] {
        didSet {
            convertImageURLsToUIImage()
            convertUIImagesToDataFormat()
        }
    }
    
    lazy var priorImageUIDs: [String] = []
    
    lazy var currentlyGatheredPeople: Int = 1
    
    //MARK: - Initialization
    
    init(postManager: PostManager, mediaManager: MediaManager) {
        self.postManager = postManager
        self.mediaManager = mediaManager
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
            mediaManager?.uploadImage(with: image) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let uid):
                    self.imageUIDs.append(uid)
                case .failure(let error):
                    self.delegate?.failedUploading(with: error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.editPostModel != nil ? self.updatePost() : self.uploadPost()
        }
    }
    
    func uploadPost() {
        
        let model = UploadPostRequestDTO(
            title: postTitle,
            location: location + 1,
            peopleGathering: totalPeopleGathering,
            imageUIDs: imageUIDs,
            detail: postDetail
        )
        
        postManager?.uploadNewPost(with: model) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(_):
                self.delegate?.didCompleteUpload()
                NotificationCenter.default.post(name: .updatePostList, object: nil)
            case .failure(let error):
                print("UploadItemViewModel - uploadItem() failed: \(error.errorDescription)")
                self.delegate?.failedUploading(with: error)
            }
        }
    }
    
    func deletePriorImagesInServerFirst() {
        
        let group = DispatchGroup()
        
        for imageUID in self.priorImageUIDs {
            
            group.enter()
            mediaManager?.deleteImage(uid: imageUID) { result in
    
                switch result {
                case .success: break
                case .failure(let error):
                    print("❗️ UploadItemViewModel - deletePriorImagesInServerFirst error: \(error.errorDescription)")
                }
                print("✏️ group.leave() called")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("✏️ Dispatch Group has ended.")
        }
        
    }
    
    func updatePost() {
        
        let model = UpdatePostRequestDTO(
            title: postTitle,
            location: location + 1,
            detail: postDetail,
            imageUIDs: imageUIDs,
            totalGatheringPeople: totalPeopleGathering,
            currentlyGatheredPeople: currentlyGatheredPeople
        )
        
        postManager?.updatePost(uid: self.editPostModel?.pageUID ?? "",
                                      with: model) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.delegate?.didUpdatePost()
                NotificationCenter.default.post(name: .didUpdatePost, object: nil)
            case .failure(let error):
                self.delegate?.failedUpdatingPost(with: error)
            }
        }
    }
    

    //MARK: - User Input Validation
    
    func validateUserInputs() throws {
        
        guard postTitle.count >= 3, postTitle.count <= 30 else {
            throw ValidationError.OnUploadPost.titleTooShortOrLong
        }
        
        print("✅ postDetail: \(postDetail)")
        print("✅ postDetail count: \(postDetail.count)")
        
        guard postDetail.count >= 3, postDetail.count < 700 else {
            throw ValidationError.OnUploadPost.detailTooShortOrLong
        }
    }
    
    //MARK: - Conversion Methods
    
    func convertUIImagesToDataFormat() {
        
        userSelectedImagesInDataFormat?.removeAll()
        
        userSelectedImagesInDataFormat = userSelectedImages.map( { (image: UIImage) -> Data in
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                return imageData
            } else {
                print("❗️ Unable to convert UIImage to Data type")
                return Data()
            }
        })
    }
    
    func convertImageURLsToUIImage() {
        
        userSelectedImages = priorImageURLs.compactMap ({ url in
        
            let imageData = try? Data(contentsOf: url)
            return UIImage(data: imageData ?? Data())
        })
    }
}
