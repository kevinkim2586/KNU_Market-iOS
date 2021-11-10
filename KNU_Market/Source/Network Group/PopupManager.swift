import Foundation
import Alamofire

class PopupManager {
    
    //MARK: - Properties
    
    static let shared = PopupManager()
    
    //MARK: - End Points
    let popupUrl        = "\(K.API_BASE_URL)popup"
    
    // 유저가 팝업 24시간 동안 보지 않기를 설정하였는지 여부
    var didUserSetToNotSeePopupForADay: Bool {
        return User.shared.didUserSetToNotSeePopupForADay
    }
    
    // 24시간이 지났는지 판별
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
    
    // 이미 유저가 본 팝업인지 판단
    func determineIfAlreadySeenPopup(uid: Int) -> Bool {
        return User.shared.userSeenPopupUids.contains(uid) ? true : false
    }
    
    // 24시간 팝업 보지 않기 설정
    func configureToNotSeePopupForOneDay() {
        User.shared.didUserSetToNotSeePopupForADay = true
        User.shared.userSetPopupBlockTime = Date()
    }
    
    // 최신 팝업 가져오기
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
    
    // 팝업 터치했을 시 - 터치했다고 서버에 알리는 함수
    func incrementPopupViewCount(popupUid: Int) {
        let url = popupUrl + "/\(popupUid)"
        
        AF.request(
            url,
            method: .get
        )
            .responseJSON { response in
                switch response.result {
                case .success: print("✏️ PopupManager - incrementPopupViewCount SUCCESS")
                case .failure: print("❗️ PopupManager - incrementPopupViewCount FAILED")
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
