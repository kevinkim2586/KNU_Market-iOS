//
//  UIViewController+Observers.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit

//MARK: - Observers

extension UIViewController {
    
    func createObserversForRefreshTokenExpiration() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTokenHasExpired),
            name: .refreshTokenExpired,
            object: nil
        )
    }
    
    func createObserversForPresentingVerificationAlert() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentUserVerificationNeededAlert),
            name: .presentVerificationNeededAlert,
            object: nil
        )
    }
    
    func createObserversForGettingBadgeValue() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureChatTabBadgeCount),
            name: .configureChatTabBadgeCount,
            object: nil
        )
    }
    
    func createObserversForUnexpectedErrors() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentUnexpectedError),
            name: .unexpectedError,
            object: nil
        )
    }
    
}
