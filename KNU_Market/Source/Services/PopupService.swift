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
    var didADayPass: Bool { get }
    
    func fetchLatestPopup() -> Single<NetworkResultWithValue<PopupModel>>
    @discardableResult
    func incrementPopupViewCount(popupUid: Int) -> Single<NetworkResult>
    func blockPopupForADay() -> Observable<Void>
}

class PopupService: PopupServiceType {
    
    let network: Network<PopupAPI>
    
    // 팝업을 띄워야하는지 안 띄워야하는지 판별
    var shouldFetchPopup: Bool {
        return didADayPass ? true : false
    }
    
    // 24시간이 지났는지 판별
    var didADayPass: Bool {
        
        //사용자가 "24시간 보지않기"를 누른 시간 가져오기 -> nil 이면 팝업 가져오기
        guard let userSetDate = User.shared.userSetPopupBlockDate else {
            return true
        }
        
        let oneDay = 86400 // 하루 == 86400초
                
        /// "24시간 보지않기"를 누른 Date 받아오기. nil 이면 팝업을 불러와야함
        if let timeDifference = Calendar.current.dateComponents([.second], from: userSetDate, to: Date()).second, timeDifference > oneDay {
            User.shared.userSetPopupBlockDate = nil     // 초기화
            return true
        } else {
            return false
        }
    }
    
    init(network: Network<PopupAPI>){
        self.network = network
    }
    
    func blockPopupForADay() -> Observable<Void> {
        User.shared.userSetPopupBlockDate = Date()
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
