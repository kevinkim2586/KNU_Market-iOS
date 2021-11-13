import Foundation
import Alamofire

class PopupManager {
    
    //MARK: - Properties
    
    static let shared = PopupManager()
    
    //MARK: - End Points
    let popupUrl        = "\(K.API_BASE_URL)popup"
    
    // 팝업을 띄워야하는지 안 띄워야하는지 판별
    var shouldFetchPopup: Bool {
        if didUserBlockPopupForADay {
            return false
        } else {
            return didADayPass ? true : false
        }
    }
    
    // 유저가 팝업 24시간 동안 보지 않기를 설정하였는지 여부
    private var didUserBlockPopupForADay: Bool {
        return User.shared.didUserBlockPopupForADay
    }
    
    // 24시간이 지났는지 판별
    private var didADayPass: Bool {
        let oneDay = 24
        guard let date = User.shared.userSetPopupBlockTime else {
            return true
        }
        if
            let timeDifference = Calendar.current.dateComponents([.hour], from: date, to: Date()).hour,
            timeDifference > oneDay {
            User.shared.didUserBlockPopupForADay = false
            return true
        }
        else { return false }
    }

    
    // 이미 유저가 본 팝업인지 판단
    func checkIfAlreadySeenPopup(uid: Int) -> Bool {
        return User.shared.userSeenPopupUids.contains(uid) ? true : false
    }
    
    // 24시간 팝업 보지 않기 설정
    func configureToNotSeePopupForOneDay() {
        User.shared.didUserBlockPopupForADay = true
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
                        completion(.success(decodedData))
                    } catch {
                        completion(.failure(.E000))
                    }
                case .failure:
                    let error = NetworkError.returnError(json: response.data ?? Data())
                    completion(.failure(error))
                }
            }
    }
    
    // 팝업 터치했을 시 - 터치했다고 서버에 알리는 함수
    func incrementPopupViewCount(popupUid: Int) {
        let url = popupUrl + "/\(popupUid)"
        AF.request(url, method: .get).responseJSON { _ in }
    }
    
    // 방금 띄운 팝업은 조회가 완료된 팝업이라고 처리 - 추후 UserDefaults 가 아닌 Realm 에 저장 예정
    func savePopupUidAsSeen(uid: Int) {
        guard var savedUidArray = UserDefaults.standard.array(
            forKey: UserDefaults.Keys.userSeenPopupUids
        ) as? [Int] else {
            User.shared.userSeenPopupUids = [uid]
            return
        }
        savedUidArray.append(uid)
        User.shared.userSeenPopupUids = savedUidArray
    }
}
