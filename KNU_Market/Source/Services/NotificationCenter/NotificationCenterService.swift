//
//  NotificationCenterService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/04.
//

import Foundation
import UIKit

enum NotificationCenterService: NotificationCenterServiceType {
    
    // Post Related
    case updatePostList
    case didUpdatePost
    
    // Chat Related
    case configureChatTabBadgeCount
    case updateChatList
    case didChooseToExitPost
    case didChooseToDeletePost
    case didBanUser
    case didBlockUser
    case didDismissPanModal
    case resetAndReconnectChat
    case reconnectAndFetchFromLastChat
    case getPreviousChats
    case getChatList
    
    // Others
    case unexpectedError
    case presentVerificationNeededAlert
    case refreshTokenExpired
    
    var name: Notification.Name {
        switch self {
        case .configureChatTabBadgeCount:
            return Notification.Name.configureChatTabBadgeCount
        case .updateChatList:
            return Notification.Name.updateChatList
        case .updatePostList:
            return Notification.Name.updatePostList
        case .didUpdatePost:
            return Notification.Name.didUpdatePost
        case .refreshTokenExpired:
            return Notification.Name.refreshTokenExpired
        case .didChooseToExitPost:
            return Notification.Name.didChooseToExitPost
        case .didChooseToDeletePost:
            return Notification.Name.didChooseToDeletePost
        case .didBanUser:
            return Notification.Name.didBanUser
        case .didBlockUser:
            return Notification.Name.didBlockUser
        case .didDismissPanModal:
            return Notification.Name.didDismissPanModal
        case .resetAndReconnectChat:
            return Notification.Name.resetAndReconnectChat
        case .reconnectAndFetchFromLastChat:
            return Notification.Name.reconnectAndFetchFromLastChat
        case .getPreviousChats:
            return Notification.Name.getPreviousChats
        case .getChatList:
            return Notification.Name.getChatList
        case .unexpectedError:
            return Notification.Name.unexpectedError
        case .presentVerificationNeededAlert:
            return Notification.Name.presentVerificationNeededAlert
        }
    }
}
