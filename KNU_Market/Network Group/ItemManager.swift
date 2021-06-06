import Foundation
import Alamofire

class ItemManager {
    
    //MARK: - Singleton
    static let shared: ItemManager = ItemManager()
    
    private init() {}
    
    //MARK: - API Request URLs
    let writePostURL                 = "\(Constants.API_BASE_URL)posts"
    
    
    
    //MARK: - 공구글 업로드
    func uploadNewItem(with model: UploadItemModel) {
        
        
    }
    
    
}
