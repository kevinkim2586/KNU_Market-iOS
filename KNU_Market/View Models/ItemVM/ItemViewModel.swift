import Foundation
import UIKit
import ImageSlideshow

protocol ItemViewModelDelegate {
    func didFetchItemDetails()
    func failedFetchingItemDetails(with error: NetworkError)
    
    func didDeletePost()
    func failedDeletingPost(with error: NetworkError)
}

class ItemViewModel {
    
    var delegate: ItemViewModelDelegate?
    
    var model: ItemDetailModel? {
        didSet { convertUIDsToURL() }
    }

    var imageURLs: [URL] = [URL]() {
        didSet { convertURLsToImageSource() }
    }
    
    var imageSources: [InputSource] = [InputSource]()
    
    let itemImages: [UIImage]? = [UIImage]()

    var isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 1
    
    var location: String {
        return Location.listForCell[model?.location ?? Location.listForCell.count]
    }
    
    var date: String {
        get {
            return formatDateForDisplay()
        }
    }
    
    //MARK: - 공구 상세내용 불러오기
    func fetchItemDetails(for uid: String) {
        
        ItemManager.shared.fetchItemDetails(uid: uid) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let fetchedModel):
                
                self.model = fetchedModel
                self.delegate?.didFetchItemDetails()
                
            case .failure(let error):
                
                print("ItemViewModel - FAILED fetchItemDetails")
                self.delegate?.failedFetchingItemDetails(with: error)
            }
        }
    }
    
    //MARK: - 본인 작성 게시글 삭제하기
    func deletePost(for uid: String) {
        
        ItemManager.shared.deletePost(uid: uid) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(_):
                self.delegate?.didDeletePost()
                
            case .failure(let error):
                print("❗️ ItemViewModel - FAILED deletePost")
                self.delegate?.failedDeletingPost(with: error)
            }
        }
    }
    
    
    
    
    func convertUIDsToURL() {
        
        imageURLs.removeAll()
        
        if let itemImageUIDs = model?.imageUIDs {
            
            imageURLs = itemImageUIDs.compactMap { URL(string: "\(Constants.API_BASE_URL)media/" + $0) }
        }
    }
    
    func convertURLsToImageSource() {
        
        imageSources.removeAll()
        
        for url in imageURLs {
            imageSources.append(SDWebImageSource(url: url,
                                                 placeholder: UIImage(named: "default item image")))
        }
    }
    
    func formatDateForDisplay() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
        let convertedDate = dateFormatter.date(from: model!.date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        
        if let date = convertedDate {
            let finalDate = dateFormatter.string(from: date)
            return finalDate
        } else {
            return "날짜 표시 에러"
        }
    }
}

