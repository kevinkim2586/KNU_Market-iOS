//
//  PopupService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import Foundation
import RxSwift

protocol PopupServiceType: AnyObject {
    
    var shouldFetchPopup: Bool { get }
    var didUserBlockPopupForADay: Bool { get }
    var didADayPass: Bool { get }
    
    func fetchLatestPopup() -> Single<NetworkResultWithValue<PopupModel>>
    @discardableResult
    func incrementPopupViewCount(popupUid: Int) -> Single<NetworkResult>
    func configureToNotSeePopupForOneDay() -> Observable<Void>
}

class PopupService: PopupServiceType {

    let network: Network<PopupAPI>
    
    // 팝업을 띄워야하는지 안 띄워야하는지 판별
    var shouldFetchPopup: Bool {
        if didUserBlockPopupForADay {
            return false
        } else {
            return didADayPass ? true : false
        }
    }
    
    // 유저가 팝업 24시간 동안 보지 않기를 설정하였는지 여부
    var didUserBlockPopupForADay: Bool {
        return User.shared.didUserBlockPopupForADay
    }
    
    // 24시간이 지났는지 판별
    var didADayPass: Bool {
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
    
    init(network: Network<PopupAPI>){
        self.network = network
    }
    
    func configureToNotSeePopupForOneDay() -> Observable<Void> {
        User.shared.didUserBlockPopupForADay = true
        User.shared.userSetPopupBlockTime = Date()
        return Observable.just(())
    }
    
    func fetchLatestPopup() -> Single<NetworkResultWithValue<PopupModel>> {
        
        network.requestObject(.fetchLatestPopup, type: PopupModel.self)
            .map { result in
                switch result {
                case .success(let popupModel):
                    return .success(popupModel)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    @discardableResult
    func incrementPopupViewCount(popupUid: Int) -> Single<NetworkResult> {
        
        network.requestWithoutMapping(.incrementPopupViewCount(uid: popupUid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
}
