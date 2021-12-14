import Foundation

struct PopupModel: ModelType {
    
    let popupUid: Int
    let title: String
    let landingUrl: String
    let imagePath: String
    let mediaUid: String
    
    enum CodingKeys: String, CodingKey {
        case popupUid = "popup_uid"
        case title = "popup_title"
        case landingUrl = "popup_landing"
        case imagePath = "media_path"
        case mediaUid = "popup_mediaUid"
    }
}
