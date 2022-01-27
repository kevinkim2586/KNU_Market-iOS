import UIKit

class PostCellViewModel {
    
    var uuid: String

    var imageUID: String? 
    
    var imageURL: URL?
    
    var title: String
  
    var isFull: Bool
    
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
    
    init(model: PostListModel) {
        self.uuid = model.uuid
        self.title = model.title
        self.price = model.price ?? 0
        self.totalGatheringPeople = model.totalGatheringPeople
        self.currentlyGatheredPeople = model.currentlyGatheredPeople
        self.isFull = model.isFull
        self.isCompletelyDone = model.isCompletelyDone
        self.shippingFee = model.shippingFee ?? 0
        self.date = model.date
        self.imageUID = model.imageUIDs.isEmpty ? nil : model.imageUIDs[0].uid
       
        if let imageUID = imageUID {
            imageURL = URL(string: K.MEDIA_REQUEST_URL + imageUID)
        }
    }
}
