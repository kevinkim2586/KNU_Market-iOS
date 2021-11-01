import Foundation
import Alamofire

class PopupManager {
    
    static let shared = PopupManager()
    
    //MARK: - End Points
    let popupUrl        = "\(K.API_BASE_URL)popup"
    
    
    func fetchLatestPopup() {
        
        AF.request(
            popupUrl,
            method: .get
        )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        
                    } catch {
                        
                    }
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ PopupManager - fetchLatestPopup error: \(error.errorDescription)")
                }
                
            }
    }
}
