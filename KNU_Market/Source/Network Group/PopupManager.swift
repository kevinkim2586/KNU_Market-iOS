import Foundation
import Alamofire

class PopupManager {
    
    //MARK: - Properties
    
    static let shared = PopupManager()
    
    //MARK: - End Points
    let popupUrl        = "\(K.API_BASE_URL)popup"
    
    // 팝업을 띄워야하는지 안 띄워야하는지 판별
    var shouldFetchPopup: Bool {
        return didADayPass ? true : false
    }

    // 24시간 동안 팝업 띄우지 않기로 설정
    func blockPopupForADay() {
        User.shared.userSetPopupBlockDate = Date()
    }
    
    // 24시간이 지났는지 판별
    private var didADayPass: Bool {
        
        //사용자가 "24시간 보지않기"를 누른 시간 가져오기 -> nil 이면 팝업 가져오기
        guard let userSetDate = User.shared.userSetPopupBlockDate else {
            return true
        }
        
        let currentDate = Date()
        let oneDay = 86400          // 하루 == 86400초
        
        /// "24시간 보지않기"를 누른 Date 받아오기. nil 이면 팝업을 불러와야함
        if let timeDifference = Calendar.current.dateComponents([.second], from: userSetDate, to: currentDate).second, timeDifference > oneDay {
            User.shared.userSetPopupBlockDate = nil     // 초기화
            return true
        } else {
            return false
        }
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
                        
                    } catch let error as DecodingError {
                        switch error {
                        case .keyNotFound(_, _): break  // 팝업이 없을 때 200은 날라오지만 decode 할게 없으니 keyNotFound error 가 뜸
                        default: completion(.failure(.E000))
                        }
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
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case .success(_):
                print("✅ success in incrementing popup viewcount")
            case .failure(_):
                print("❗️ error in incrementing popup viewcount")
            }
        }
    }
}
