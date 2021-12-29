//
//  PopupServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
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
