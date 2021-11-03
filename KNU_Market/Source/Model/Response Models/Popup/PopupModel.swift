import Foundation

struct PopupModel: Decodable {
    
    let popupUid: Int
    let title: String
    let landingUrl: String
    let imagePath: String
    
    enum CodingKeys: String, CodingKey {
        case popupUid = "popup_uid"
        case title = "popup_title"
        case landingUrl = "popup_landing"
        case imagePath = "media_path"
    }
}
