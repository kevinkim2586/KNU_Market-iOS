import Foundation

struct EditPostModel {
    
    let title: String
    let imageURLs: [URL]?
    let imageUIDs: [String]?
    let totalGatheringPeople: Int
    let currentlyGatheredPeople: Int
    let location: Int
    let itemDetail: String
    let pageUID: String
}
