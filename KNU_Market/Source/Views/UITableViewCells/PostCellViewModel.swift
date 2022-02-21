import UIKit

class PostCellViewModel {
    
    var uuid: String
    var imageURL: URL?
    var title: String
    var isCompletelyDone: Bool
    var currentlyGatheredPeople: Int
    var totalGatheringPeople: Int
    var price: Int
    var shippingFee: Int
    
    var priceForEachPerson: String {
        let perPersonPrice = (price + shippingFee) / totalGatheringPeople
        return perPersonPrice.withDecimalSeparator
    }

    private var formattedDate: String = ""
    var date: String {
        get {
            return formattedDate
        }
        set {
            formattedDate = DateConverter.convertDateStringToComplex(newValue)
        }
    }
    
    init(model: PostModel) {
        self.uuid = model.postID
        self.title = model.title
        self.price = model.price ?? 0
        self.totalGatheringPeople = model.headCount
        self.currentlyGatheredPeople = model.currentHeadCount
      
        self.isCompletelyDone = model.isRecruited == 1 ? true : false
        self.shippingFee = model.shippingFee ?? 0
        self.date = model.createdAt
        
        if let postFile = model.postFile, let location = postFile.files[0].location {
            self.imageURL = URL(string: location)
        }
    }
}
