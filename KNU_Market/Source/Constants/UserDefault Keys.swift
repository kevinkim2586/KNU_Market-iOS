import Foundation

extension UserDefaults {
    
    enum Keys {
        
        static let userUID                      = "userUID"
        static let userID                       = "userID"
        static let nickname                     = "nickname"
        static let emailForPasswordLoss         = "emailForPasswordLoss"
        static let profileImageUID              = "profileImageUID"
        static let isLoggedIn                   = "isLoggedIn"
        static let hasVerifiedEmail             = "hasVerifiedEmail"
        static let fcmToken                     = "fcmToken"
        static let notificationList             = "notificationList"
        static let hasAllowedForNotification    = "hasAllowedForNotification"
        static let bannedPostUploaders          = "bannedPostUploaders"
        static let bannedChatUsers              = "bannedChatUsers"
        static let isNotFirstAppLaunch          = "isNotFirstAppLaunch"
        static let postFilterOptions            = "postFilterOptions"
        static let joinedChatRoomPIDs           = "joinedChatRoomPIDs"
    }
}
