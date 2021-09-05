import UIKit

struct Constants {
    
    static let API_BASE_URL                     = "https://knumarket.kro.kr:5051/api/v1/"
    static let WEB_SOCKET_URL                   = "wss://knumarket.kro.kr:5052"
    
    //MARK: - Identifiers
    
    struct SegueID {
        
        // UserRegister Segues
        static let goToRegister                 = "goToRegister"
        static let goToPasswordInputVC          = "goToPasswordInputVC"
        static let goToProfilePictureVC         = "goToProfilePictureVC"
        static let goToEmailInputVC             = "goToEmailInputVC"
        static let goToCheckEmailVC             = "goToCheckEmailVC"
        
        // Chat
        static let presentChatMemberVC          = "presentChatMemberVC"

        
        static let goToItemVC                   = "goToItemVC"
        static let goToItemVCFromMyPosts        = "goToItemVCFromMyPosts"
        
        static let goToReportVC                 = "goToReportVC"
        
    }
    
    struct StoryboardID {
        
        // Register  & Login
        static let initialVC                    = "initialViewController"
        static let initialNavigationController  = "InitialNavigationController"
        static let loginVC                      = "LoginViewController"
        static let registerVC                   = "RegisterViewController"
        static let congratulateUserVC           = "CongratulateViewController"
        static let registerNavigationController = "RegisterNavigationController"
        static let findPasswordVC               = "FindPasswordViewController"
    
        
        // Home & Item Tab
        static let tabBarController             = "TabBarController"
        static let homeVC                       = "HomeViewController"
        static let itemVC                       = "ItemViewController"
        static let uploadItemVC                 = "UploadItemViewController"
        static let photoDetailVC                = "PhotoDetailViewController"
        static let searchPostVC                 = "SearchPostViewController"
        
        // Chat Tab
        static let chatVC                       = "ChatViewController"
        static let chatMemberVC                 = "ChatMemberViewController"
        
        // My Page Tab
        static let myPostsVC                    = "MyPostsViewController"
        static let settingsVC                   = "SettingsViewController"
        static let unregisterUserInputSuggestVC = "UnregisterUser_InputSuggestionViewController"
        static let sendDeveloperMessageVC       = "SendDeveloperMessageViewController"
        static let termsAndConditionsVC         = "TermsAndConditionViewController"
        static let developerInfoVC              = "DeveloperInfoViewController"
        static let openSourceLicenseVC          = "OpenSourceLicenseViewController"
        
        // Others
        static let reportUserVC                 = "ReportUserViewController"
        static let verifyEmailVC                = "VerifyEmailViewController"
        
        
        // My Page UITableView ID Array
        static let myPageSection_1_Options      = [myPostsVC, settingsVC]
        static let myPageSection_2_Options      = [sendDeveloperMessageVC, termsAndConditionsVC, openSourceLicenseVC, developerInfoVC]

    }
    
    struct cellID {
        
        static let itemTableViewCell            = "itemTableViewCell"
        static let chatTableViewCell            = "chatTableViewCell"
        static let addItemImageCell             = "addItemImageCell"
        static let userPickedItemImageCell      = "userPickedItemImageCell"
        static let sendCell                     = "sendCell"
        static let receiveCell                  = "receiveCell"
        static let myPageCell                   = "myPageCell"
        static let chatMemberCell               = "chatMemberCell"
    }
    
    //MARK: - Keys
    
    struct KeyChainKey {
        
        static let accessToken                  = "accessToken"
        static let refreshToken                 = "refreshToken"
        static let password                     = "password"
    }
    
    struct UserDefaultsKey {
        
        static let userUID                      = "userUID"
        static let userID                       = "userID"
        static let nickname                     = "nickname"
        static let profileImageUID              = "profileImageUID"
        static let isLoggedIn                   = "isLoggedIn"
        static let hasVerifiedEmail             = "hasVerifiedEmail"
        static let fcmToken                     = "fcmToken"
        static let notificationList             = "notificationList"
        static let hasAllowedForNotification    = "hasAllowedForNotification"
        static let bannedPostUploaders          = "bannedPostUploaders"
        static let bannedChatUsers              = "bannedChatUsers"
    }
    
    struct NotificationKey {
        
        static let updateChatList               = "co.wim.updateChatList"
        static let updateItemList               = "co.wim.updateItemList"
        
    }
    
    static let entireChatRoomUID                = "__entireRoomPid"
    
    //MARK: - UI Related Constants
    
    struct XIB {
        
        static let sendCell                     = "SendCell"
        static let receiveCell                  = "ReceiveCell"
        static let itemTableViewCell            = "ItemTableViewCell"
    }
    
    struct Color {
        
        static let appColor                     = "AppDefaultColor"
        static let borderColor                  = "BorderColor"
        static let backgroundColor              = "BackgroundColor"
    }
    
    struct Images {
        
        // PlaceHolder & Default Images
        static let appLogo                      = "appLogo"
        static let appLogoWithPhrase            = "appLogoWithPhrase"
        
        static let defaultAvatar                = "default avatar"
        static let defaultItemIcon              = "default item icon"
        static let defaultItemImage             = "default item image"
        static let defaultProfileImage          = "default_profile_image"
        static let pickProfileImage             = "pick profile image"
        static let peopleIcon                   = "people icon"
        static let chatMemberDefaultImage       = "chatMemberDefaultImage"
        static let emptySearchPlaceholder       = "search placeholder"
        static let emptyChat_1                  = "empty_chat_1"
        static let emptyChat_2                  = "empty_chat_2"
        static let emptyChatRandomImage         = ["empty_chat_1","empty_chat_2"]
        static let emptyChatList                = "empty_chatList"
        
        static let chatBubbleIcon               = "chat_bubble_icon"
        
        static let cameraIcon                   = "camera icon"
        
        // Tab Bar Icons
        static let chatUnselected               = "grey chat"
        static let chatSelected                 = "chat"
        static let homeUnselected               = "grey house"
        static let homeSelected                 = "house"
        static let myPageUnselected             = "grey my"
        static let myPageSelected               = "my"
        
        
        // Item View Controller Images
        static let locationIcon                 = "location icon"
        
        
        // Other
        static let myPageSection_1_Images         = [
                                                    "tray.full",
                                                    "gear",
                                                    ]
        
        static let myPageSection_2_Images         = [
                                                   "paperplane",
                                                   "doc.text",
                                                    "hand.raised",
                                                   "info.circle"
                                                    ]

    }
    
    //MARK: - Others
    
    struct DateFormat {
        
        static let defaultFormat                = "yyyy-MM-dd HH:mm:ss"
    }
        
    struct ChatSuffix {
        
        static let emptySuffix                  = "__EMPTY_SUFFIX"
        static let enterSuffix                  = "님이 채팅방에 입장했습니다.__ENTER_SUFFIX"
        static let exitSuffix                   = "님이 채팅방에서 나가셨습니다.__EXIT_SUFFIX"
        
        static let rawBanSuffix                 = "__BAN_SUFFIX"
        static let rawEnterSuffix               = "__ENTER_SUFFIX"
        static let rawExitSuffix                = "__EXIT_SUFFIX"
        
        static let usedBanSuffix                = "방장이 강퇴 기능을 사용했습니다!🪄"
    }
    
    struct placeHolderTitle {
        
        static let prepareSearchTitleList       = ["지금 당신이 공구하고 싶은 것은?",
                                                   "지금 소누가 공구하고 싶은 것은...?"]
        
        static let emptySearchTitleList         = ["검색 결과가 없네요!\n지금 무엇이 필요하신가요?",
                                                   "검색 결과가 없네요!\n지금 공구하고 싶은게 뭔가요?"]
        
        static let emptyChatRandomTitle         = ["개인정보 보호를 위해 카카오톡 ID,\n전화번호 등의 정보는 공개하지 않는\n것을 권장합니다!",
                                                   "소누 거래물품 들고 달려가는 중~!",
                                                    "부적절하거나 불쾌감을\n줄 수 있는 대화는 삼가 부탁드립니다."]
    }
    
    struct URL {
        
        static let termsAndConditionNotionURL       = "https://linen-twister-e2b.notion.site/b02ec80599d14452aefff7e0dcfcf4ff"
        static let privacyInfoConditionNotionURL    = "https://linen-twister-e2b.notion.site/6554bde75b2c49bfb617b04f526aad6e"
    }
}

//MARK: - Caches
let profileImageCache = NSCache<AnyObject, AnyObject>()

//MARK: - Notifications

struct ChatNotifications {
    
    static var list: [String] = [String]() {
        didSet {
            UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKey.notificationList)
            UserDefaults.standard.set(list,
                                      forKey: Constants.UserDefaultsKey.notificationList)
        }
    }
}
