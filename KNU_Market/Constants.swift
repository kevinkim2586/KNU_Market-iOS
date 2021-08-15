import UIKit

//MARK: - Caches
let profileImageCache = NSCache<AnyObject, AnyObject>()

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
        
        
        
        
        static let chatBubbleIcon               = "chat_bubble_icon"
        
        static let cameraIcon                   = "camera icon"
        
        // Tab Bar Icons
        static let chatUnselected               = "chat_unselected"
        static let chatSelected                 = "chat_selected"
        static let homeUnselected               = "home_unselected"
        static let homeSelected                 = "home_selected"
        static let myPageUnselected             = "mypage_unselected"
        static let myPageSelected               = "mypage_selected"
        
        
        
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
                                                   "info.circle",
                                                   "book.closed"
                                                    ]

    }
    
    //MARK: - Others
    
    struct DateFormat {
        
        static let defaultFormat                = "yyyy-MM-dd HH:mm:ss"
    }
    
    struct URL {
        

    }
    
    struct ChatSuffix {
        
        static let emptySuffix                  = "__EMPTY_SUFFIX"
        static let enterSuffix                  = "님이 채팅방에 입장했습니다.__ENTER_SUFFIX"
        static let exitSuffix                   = "님이 채팅방에서 나가셨습니다.__EXIT_SUFFIX"
        
    }
}
