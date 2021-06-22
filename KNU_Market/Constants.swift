import Foundation

struct Constants {
    
    static let API_BASE_URL                     = "http://155.230.25.110:5004/api/v1/"
    
    struct KeyChainKey {
        
        static let accessToken                  = "accessToken"
        static let refreshToken                 = "refreshToken"
        static let password                     = "password"
    }
    
    struct SegueID {
        static let goToItemVC                   = "goToItemVC"
    }
    
    struct Color {
        
        static let appColor                     = "AppDefaultColor"
        static let borderColor                  = "BorderColor"
        static let backgroundColor              = "BackgroundColor" 
    }
    
    struct StoryboardID {
        
        static let initialVC                    = "initialViewController"
        static let initialNavigationController  = "InitialNavigationController"
        static let tabBarController             = "TabBarController"
        static let homeVC                       = "HomeViewController"
        static let itemVC                       = "itemViewController"
        static let uploadItemVC                 = "UploadItemViewController"
        static let photoDetailVC                = "PhotoDetailViewController"
        
        
        
        static let sendDeveloperMessageVC       = "SendDeveloperMessageViewController"
        static let settingsVC                   = "SettingsViewController"
        static let termsAndConditionsVC         = "TermsAndConditionViewController"
        
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
    
    struct XIB {
        
        static let sendCell                     = "SendCell"
        static let receiveCell                  = "ReceiveCell"
    }
    
    
    

    
}
