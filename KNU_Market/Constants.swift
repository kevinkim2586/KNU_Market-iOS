import Foundation

struct Constants {
    
    static let API_BASE_URL = "http://155.230.25.110:5004/api/v1/"
    
    struct Color {
        
        static let appColor = "AppDefaultColor"
        static let borderColor = "borderColor"
    }
    
    struct StoryboardID {
        
        static let initialViewController        = "initialViewController"
        static let loginNavigationController    = "LoginNavigationController"
        static let tabBarController             = "TabBarController"
        static let itemViewController           = "itemViewController"
    }
    
    struct cellID {
        
        static let itemTableViewCell            = "itemTableViewCell"
        static let chatTableViewCell            = "chatTableViewCell"
        static let addItemImageCell             = "addItemImageCell"
        static let userPickedItemImageCell      = "userPickedItemImageCell"
        static let sendCell                     = "sendCell"
        static let receiveCell                  = "receiveCell"
    }
    
    struct XIB {
        
        static let sendCell                     = "SendCell"
        static let receiveCell                  = "ReceiveCell"
    }
    
    struct Colors {
        
        static let appDefaultColor              = "AppDefaultColor"
    }
    
}
