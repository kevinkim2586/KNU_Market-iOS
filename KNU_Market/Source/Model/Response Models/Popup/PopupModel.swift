import Foundation

struct PopupModel: Decodable {
    
    let uid: Int
    let title: String
    let mediaUid: String
    let landingUrl: String
    
    enum CodingKeys: String, CodingKey {
        case uid, title, mediaUid
        case landingUrl = "landing"
    }
}
