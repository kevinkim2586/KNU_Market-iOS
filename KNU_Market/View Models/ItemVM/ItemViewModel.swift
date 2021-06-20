import Foundation
import UIKit

protocol ItemViewModelDelegate {
    func didFetchItemDetails()
    func failedFetchingItemDetails(with error: NetworkError)
}

class ItemViewModel {
    
    var delegate: ItemViewModelDelegate?
    
    var model: ItemDetailModel? {
        didSet { convertUIDsToURL() }
    }

    var imageURLs: [URL] = [URL]()
    
    let itemImages: [UIImage]? = [UIImage]()

    var isGathering: Bool = true
    
    var currentlyGatheredPeople: Int = 1
    
    var location: String {
        return Location.listForCell[model?.location ?? Location.listForCell.count]
    }

    //MARK: - Methods
    
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
    
    func convertUIDsToURL() {
        
        if let itemImageUIDs = model?.imageUIDs {
            
            imageURLs = itemImageUIDs.compactMap { URL(string: "\(Constants.API_BASE_URL)media/" + $0) }
        }
    }
}

