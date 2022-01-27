//
//  URLNavigatorType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/27.
//

import Foundation

protocol URLNavigatorType {
    func handleReceivedNotification(with userInfo: [AnyHashable : Any])
    func navigateToChatListVC()
}
