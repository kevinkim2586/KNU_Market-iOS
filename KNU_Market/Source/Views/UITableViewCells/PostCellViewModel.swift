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
    
    var location: Int
    
    var locationName: String {
        
        let index = location - 1
        guard index != Location.list.count || index >= Location.list.count else {
            return Location.listForCell[Location.listForCell.count - 1]
        }
        return Location.listForCell[index]
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
            let calendar = Calendar.current
            
            if calendar.isDateInToday(convertedDate) {
                dateFormatter.dateFormat = "오늘\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            } else if calendar.isDateInYesterday(convertedDate) {
                dateFormatter.dateFormat = "어제\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            } else {
                dateFormatter.dateFormat = "MM/dd\nHH:mm"
                formattedDate = dateFormatter.string(from: convertedDate)
            }
        }
    }
    
 
    init(model: PostListModel) {
        
        self.uuid = model.uuid
        self.title = model.title
        self.location = model.location
        self.totalGatheringPeople = model.totalGatheringPeople
        self.currentlyGatheredPeople = model.currentlyGatheredPeople
        self.isFull = model.isFull
        self.isCompletelyDone = model.isCompletelyDone
        self.date = model.date
        self.imageUID = model.imageUIDs.isEmpty ? nil : model.imageUIDs[0].uid
       
        if let imageUID = imageUID {
            imageURL = URL(string: "\(K.API_BASE_URL)media/" + imageUID)
        }
    }
    
    
}
