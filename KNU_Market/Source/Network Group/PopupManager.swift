import Foundation
import Alamofire

class PopupManager {
    
    //MARK: - Properties
    
    static let shared = PopupManager()
    
    //MARK: - End Points
    let popupUrl        = "\(K.API_BASE_URL)popup"
    
    var didUserSetToNotSeePopupForADay: Bool {
        return User.shared.didUserSetToNotSeePopupForADay
    }
    
    var didADayPass: Bool {
        
        let oneDay = 24
        let date = User.shared.userSetPopupBlockTime
        if
            let timeDifference = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour,
            timeDifference > oneDay {
            User.shared.didUserSetToNotSeePopupForADay = false // 필요?
            return true
        }
        else { return false }
    }
    
    func determineIfAlreadySeenPopup(uid: Int) -> Bool {
        return User.shared.userSeenPopupUids.contains(uid) ? true : false
    }
    
    func configureToNotSeePopupForOneDay() {
        User.shared.didUserSetToNotSeePopupForADay = true
        User.shared.userSetPopupBlockTime = Date()
    }
    
    func fetchLatestPopup(completion: @escaping ((Result<PopupModel, NetworkError>) ->Void)) {
        AF.request(
            popupUrl,
            method: .get
        )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        let decodedData = try JSONDecoder().decode(PopupModel.self, from: response.data ?? Data())
//                        self.saveSeenPopupUid(uid: decodedData.popupUid)
                        completion(.success(decodedData))
                    } catch {
                        print("❗️ PopupManager - fetchLatestPopup error: \(error)")
                        completion(.failure(.E000))
                    }
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    print("❗️ PopupManager - fetchLatestPopup error: \(error.errorDescription)")
                }
                
            }
    }
    
    private func saveSeenPopupUid(uid: Int) {
        
        // UserDefaults 에 저장되어 있는
        guard var savedUidArray = UserDefaults.standard.array(
            forKey: UserDefaults.Keys.userSeenPopupUids
        ) as? [Int] else { return }
        
        savedUidArray.append(uid)
        User.shared.userSeenPopupUids = savedUidArray
    }
}
