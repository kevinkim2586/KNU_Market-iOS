//
//  URLNavigatorType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/27.
//

import Foundation
import FirebaseDynamicLinks

protocol URLNavigatorType {
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink)
    func handleReceivedNotification(with userInfo: [AnyHashable : Any])
    func navigateToChatListVC()
}
