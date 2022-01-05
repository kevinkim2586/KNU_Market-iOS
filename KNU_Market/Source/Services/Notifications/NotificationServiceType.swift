//
//  NotificationServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/04.
//

import Foundation
import RxSwift

protocol NotificationServiceType {
    var name: Notification.Name { get }
}

//MARK: - Generic Method Extension

extension NotificationServiceType {
    
    func addObserver() -> Observable<Any?> {
        return NotificationCenter.default.rx.notification(self.name).map { $0.object }
    }

    func post(object: Any? = nil) {
        NotificationCenter.default.post(name: self.name, object: object, userInfo: nil)
    }
}
