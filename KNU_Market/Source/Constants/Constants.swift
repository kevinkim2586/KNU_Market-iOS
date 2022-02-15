import UIKit

//MARK: - Struct for managing constants

struct K {

    static let API_BASE_URL                     = "http://222.104.199.114:5100/api/"
    static let WEB_SOCKET_URL                   = "ws://222.104.199.114:5005"
    
//    static let API_BASE_URL                     = "https://knumarket.kro.kr:5051/api/v1/"           // 실 배포 서버
//    static let WEB_SOCKET_URL                   = "wss://knumarket.kro.kr:5052"                     // 실 배포 서버

    static let MEDIA_REQUEST_URL                = "\(K.API_BASE_URL)media/"
    
    
    //MARK: - Keys
    
    struct KeyChainKey {
        static let accessToken                  = "accessToken"
        static let refreshToken                 = "refreshToken"
    }
    

    static let entireChatRoomUID                = "__entireRoomPid"
    
    //MARK: - UI Related Constants
    
    struct Fonts {
        
        // NotoSans
        static let notoSansRegular              = "NotoSans-Regular"
        static let notoSansBold                 = "NotoSans-Bold"
        
        // NotoSans KR
        static let notoSansKRRegular            = "NotoSansKR-Regular"
        static let notoSansKRMedium             = "NotoSansKR-Medium"
        static let notoSansKRBold               = "NotoSansKR-Bold"
        static let notoSansKRLight              = "NotoSansKR-Light"
        
        // Roboto
        static let robotoRegular                = "Roboto-Regular"
        static let robotoBold                   = "Roboto-Bold"
        static let robotoMedium                 = "Roboto-Medium"
        static let robotoBlack                  = "Roboto-Black"
        
    }
    
    struct Color {
        
        static let appColor                     = "AppDefaultColor"
        static let borderColor                  = "BorderColor"
        static let backgroundColor              = "BackgroundColor"
        static let appColorEnforced             = "AppDefaultColorEnforced"
    }
    
    struct Images {
        
        // PlaceHolder & Default Images
        static let appLogo                      = "appLogo"
        static let appLogoWithPhrase            = "appLogoWithPhrase"
        static let developerInfo                = "developer_info"
        
        static let defaultUserPlaceholder       = "defaultUserImagePlaceholder"
        static let defaultAvatar                = "default avatar"
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
        static let homeMenuIcon                 = "menu"
        
        // Tab Bar Icons
        static let chatUnselected               = "chatTabIcon_Unselected"
        static let chatSelected                 = "chatTabIcon"
        static let homeUnselected               = "homeTabIcon_UnSelected"
        static let homeSelected                 = "homeTabIcon"
        static let myPageUnselected             = "myPageTabIcon_Unselected"
        static let myPageSelected               = "myPageTabIcon"
        
        
        // Post View Controller Images
        static let locationIcon                 = "location icon"
        
        
        // Verify Button
        static let studentIdButtonSystemImage   = "person.crop.rectangle"
        static let schoolMailButtonSystemImage  = "envelope"
        
        
        // Other
        static let myPageSection_1_Images         = [
                                                    "tray.full",
                                                    "gear",
                                                    "checkmark.circle"
                                                    ]
        
        static let myPageSection_2_Images         = [
                                                   "talk_with_team_icon",
                                                   "doc.text",
                                                    "hand.raised",
                                                   "info.circle"
                                                    ]
        
        static let studentIdGuideImage              = "studentID_guide"

    }
    
    //MARK: - Others
    
    struct DateFormat {
        
        static let defaultFormat                = "yyyy-MM-dd HH:mm:ss"
    }
    
    struct ChatSuffix {
        
        static let emptySuffix                  = "__EMPTY_SUFFIX"
        static let imageSuffix                  = "__IMAGE_SUFFIX"
        
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
        
        static let kakaoHelpChannel                 = "https://pf.kakao.com/_PjLHs"
        static let appStoreLink                     = "https://apps.apple.com/kr/app/%ED%81%AC%EB%88%84%EB%A7%88%EC%BC%93/id1580677279"
    }
}

//MARK: - Caches
let profileImageCache = NSCache<AnyObject, AnyObject>()

//MARK: - Notifications

struct ChatNotifications {
    
    static var list: [String] = [String]() {
        didSet {
            UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.notificationList)
            UserDefaults.standard.set(list,
                                      forKey: UserDefaults.Keys.notificationList)
        }
    }
}
