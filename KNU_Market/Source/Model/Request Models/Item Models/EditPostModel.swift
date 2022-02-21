import UIKit

struct EditPostModel {
    
    let pageUID: String
    let title: String
    let content: String
    let location: Int = Location.list.count
    let headCount: Int
    let currentlyGatheredPeople: Int
    let price: Int
    let shippingFee: Int
    let referenceUrl: String?
    let imageFiles: [File]?
}
