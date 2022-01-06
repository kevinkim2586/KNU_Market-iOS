import UIKit

extension Notification.Name {
    
    // Post Related
    
    static let updatePostList                       = Notification.Name("co.wim.updateItemList")
    static let didUpdatePost                        = Notification.Name("co.wim.didUpdatePost")
    
    // Chat Related
    
    static let configureChatTabBadgeCount           = Notification.Name("co.wim.configureChatTabBadgeCount")
    static let updateChatList                       = Notification.Name("co.wim.updateChatList")

    static let didChooseToExitPost                  = Notification.Name("co.wim.didChooseToExitPost")
    static let didChooseToDeletePost                = Notification.Name("co.wim.didChooseToDeletePost")
    static let didBanUser                           = Notification.Name("co.wim.didBanUser")
    static let didBlockUser                         = Notification.Name("co.wim.didBlockUser")
    static let didDismissPanModal                   = Notification.Name("co.wim.didDismissPanModal")
    static let resetAndReconnectChat                = Notification.Name("co.wim.resetAndReconnectChat")
    static let reconnectAndFetchFromLastChat        = Notification.Name("co.wim.reconnectAndFetchFromLastChat")
    static let getPreviousChats                     = Notification.Name("co.wim.getPreviousChats")
    static let getChatList                          = Notification.Name("co.wim.getChatList")
            
    // Others
    
    static let unexpectedError                      = Notification.Name("co.wim.unexpectedError")
    static let presentVerificationNeededAlert       = Notification.Name("co.wim.presentVerifyEmailVC")
    static let refreshTokenExpired                  = Notification.Name("co.wim.refreshTokenExpired")
}
