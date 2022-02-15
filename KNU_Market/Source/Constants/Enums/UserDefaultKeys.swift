import Foundation

extension UserDefaults {
    
    enum Keys {
        
        static let userUID                          = "userUID"
        static let username                         = "username" //로그인할 때 쓰는 아이디
        static let displayName                      = "displayName"
        static let emailForPasswordLoss             = "emailForPasswordLoss"
        static let profileImageUID                  = "profileImageUID"
        static let bannedTo                         = "bannedTo"
        
        
        static let isReportChecked                  = "isReportChecked"
        
        static let isLoggedIn                       = "isLoggedIn"
        static let hasVerifiedEmail                 = "hasVerifiedEmail"
        static let fcmToken                         = "fcmToken"
        static let notificationList                 = "notificationList"
        static let hasAllowedForNotification        = "hasAllowedForNotification"
        static let bannedPostUploaders              = "bannedPostUploaders"
        static let bannedChatUsers                  = "bannedChatUsers"
        static let isNotFirstAppLaunch              = "isNotFirstAppLaunch"
        static let postFilterOptions                = "postFilterOptions"


        
        static let joinedChatRoomPIDs               = "joinedChatRoomPIDs"
        
        static let userSeenPopupUids                = "userSeenPopupUids"
        static let userSetPopupBlockDate            = "userSetPopupBlockDate"
    }
}
