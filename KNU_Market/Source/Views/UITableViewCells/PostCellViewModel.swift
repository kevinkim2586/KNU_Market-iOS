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
    
    var priceForEachPerson: String {
        let perPersonPrice = price / totalGatheringPeople
        return perPersonPrice.withDecimalSeparator
    }

    private var formattedDate: String = ""
    var date: String {
        get {
            return formattedDate
        }
        set {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier:"ko_KR")
            guard let convertedDate = dateFormatter.date(from: newValue) else {
                formattedDate = "날짜 표시 에러"
                return
            }
            formattedDate = DateConverter.convertDateForPostTVC(convertedDate)
        }
    }
    
    init(model: PostListModel) {
        
        self.uuid = model.uuid
        self.title = model.title
        self.price = model.price
        self.totalGatheringPeople = model.totalGatheringPeople
        self.currentlyGatheredPeople = model.currentlyGatheredPeople
        self.isFull = model.isFull
        self.isCompletelyDone = model.isCompletelyDone
        self.date = model.date
        self.imageUID = model.imageUIDs.isEmpty ? nil : model.imageUIDs[0].uid
       
        if let imageUID = imageUID {
            imageURL = URL(string: K.MEDIA_REQUEST_URL + imageUID)
        }
    }
    
    
}
