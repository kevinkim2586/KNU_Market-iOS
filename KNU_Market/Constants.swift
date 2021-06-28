import Foundation

struct Constants {
    
    static let API_BASE_URL                     = "http://155.230.25.110:5004/api/v1/"
    
    //MARK: - Identifiers
    
    struct SegueID {
        
        static let goToItemVC                   = "goToItemVC"
    }
    
    struct StoryboardID {
        
        // Register  & Login
        static let initialVC                    = "initialViewController"
        static let initialNavigationController  = "InitialNavigationController"
        static let loginVC                      = "LoginViewController"
        static let registerVC                   = "RegisterViewController"
        
        
        static let tabBarController             = "TabBarController"
        static let homeVC                       = "HomeViewController"
        static let itemVC                       = "itemViewController"
        static let uploadItemVC                 = "UploadItemViewController"
        static let photoDetailVC                = "PhotoDetailViewController"
        
    
        static let sendDeveloperMessageVC       = "SendDeveloperMessageViewController"
        static let settingsVC                   = "SettingsViewController"
        static let termsAndConditionsVC         = "TermsAndConditionViewController"
        static let reportUserVC                 = "ReportUserViewController"
        
    }
    
    struct cellID {
        
        static let itemTableViewCell            = "itemTableViewCell"
        static let chatTableViewCell            = "chatTableViewCell"
        static let addItemImageCell             = "addItemImageCell"
        static let userPickedItemImageCell      = "userPickedItemImageCell"
        static let sendCell                     = "sendCell"
        static let receiveCell                  = "receiveCell"
        static let myPageCell                   = "myPageCell"
    }
    
    //MARK: - Keys
    
    struct KeyChainKey {
        
        static let accessToken                  = "accessToken"
        static let refreshToken                 = "refreshToken"
        static let password                     = "password"
    }
    
    struct UserDefaultsKey {
        
        static let userID                       = "userID"
        static let nickname                     = "nickname"
        static let profileImageUID              = "profileImageUID"
        static let isLoggedIn                   = "isLoggedIn"
    }
    
    //MARK: - UI Related Constants
    
    struct XIB {
        
        static let sendCell                     = "SendCell"
        static let receiveCell                  = "ReceiveCell"
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
        static let pickProfileImage             = "pick profile image"
        
        // Tab Bar Icons
        
        
        // Item View Controller Images
        static let locationIcon                 = "location icon"
        
        
        // Other
        
    }
    

    
}
