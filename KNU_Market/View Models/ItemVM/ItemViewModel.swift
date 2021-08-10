import Foundation
import UIKit
import ImageSlideshow

protocol ItemViewModelDelegate: AnyObject {
    func didFetchItemDetails()
    func failedFetchingItemDetails(with error: NetworkError)
    
    func didDeletePost()
    func failedDeletingPost(with error: NetworkError)
    
    func didMarkPostDone()
    func failedMarkingPostDone(with error: NetworkError)
    
    func didEnterChat()
    func failedJoiningChat(with error: NetworkError)
}

class ItemViewModel {
    
    weak var delegate: ItemViewModelDelegate?
    
    var pageID: String?
    
    var model: ItemDetailModel? {
        didSet { convertUIDsToURL() }
    }

    var imageURLs: [URL] = [URL]() {
        didSet { convertURLsToImageSource() }
    }
    
    var imageSources: [InputSource] = [InputSource]()
    
    let itemImages: [UIImage]? = [UIImage]()
    
    var currentlyGatheredPeople: Int {
        return self.model?.currentlyGatheredPeople ?? 1
    }
    
    var totalGatheringPeople: Int {
        return self.model?.totalGatheringPeople ?? 2
    }
    
    var location: String {
        return Location.listForCell[model?.location ?? Location.listForCell.count - 1]
    }
    
    var date: String {
        return formatDateForDisplay()
    }
    
    // 내가 올린 공구인지
    var postIsUserUploaded: Bool {
        return model?.nickname == User.shared.nickname
    }

    // 이미 참여하고 있는 공구인지
    var userAlreadyJoinedPost: Bool {
        if User.shared.joinedChatRoomPIDs.contains(self.pageID ?? "") {
            return true
        }
        return false
    }
    
    // 공구 자체가 다 마감이 됐는지
    var isFull: Bool {
        return model?.isFull ?? true
    }
    
    // 인원이 다 찼는지
    var isCompletelyDone: Bool {
        return model?.isCompletelyDone ?? true
    }
    
    var isGathering: Bool {
        
        if isFull || isCompletelyDone {
            return false
        } else {
            return true
        }
    }
    
    
    
    var modelForEdit: EditPostModel {
        let editPostModel = EditPostModel(title: self.model?.title ?? "",
                                          imageURLs: self.imageURLs,
                                          imageUIDs: self.model?.imageUIDs,
                                          totalGatheringPeople: self.totalGatheringPeople,
                                          currentlyGatheredPeople: self.currentlyGatheredPeople,
                                          location: self.model?.location ?? 0,
                                          itemDetail: self.model?.itemDetail ?? "",
                                          pageUID: self.pageID ?? "")
        return editPostModel
    }
    

    
    //MARK: - 공구 상세내용 불러오기
    func fetchItemDetails(for uid: String) {
        
        ItemManager.shared.fetchItemDetails(uid: uid) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let fetchedModel):
                
                self.model = fetchedModel
                self.delegate?.didFetchItemDetails()
                
            case .failure(let error):
                
                print("❗️ ItemViewModel - FAILED fetchItemDetails")
                self.delegate?.failedFetchingItemDetails(with: error)
            }
        }
    }
    
    //MARK: - 본인 작성 게시글 삭제하기
    func deletePost(for uid: String) {
        
        ItemManager.shared.deletePost(uid: uid) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(_):
                self.delegate?.didDeletePost()
                
            case .failure(let error):
                self.delegate?.failedDeletingPost(with: error)
            }
        }
    }
    
    //MARK: - 공구글 완료 표시
    func markPostDone(for uid: String) {
        
        ItemManager.shared.markPostDone(uid: uid) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.delegate?.didMarkPostDone()
                
            case .failure(let error):
                self.delegate?.failedMarkingPostDone(with: error)
            }
        }
    }
    
    func joinPost() {
        
        print("✏️ pageID: \(self.pageID)")
        
        ChatManager.shared.changeJoinStatus(function: .join,
                                            pid: self.pageID ?? "error") { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success:
                
                self.delegate?.didEnterChat()
                
            case .failure(let error):
                
                print("❗️ ItemViewModel - joinPost error: \(error)")
                
                // 이미 참여하고 있는 채팅방이면 성공은 성공임. 그러나 기존의 메시지를 불러와야함
                if error == .E108 {
                    
                    self.delegate?.didEnterChat()
         
                
                } else {
                    self.delegate?.failedJoiningChat(with: error)
                }
            }
        }
    }
    
    

}

//MARK: - Conversion Methods

extension ItemViewModel {
    
    func convertUIDsToURL() {
        
        self.imageURLs.removeAll()
        
        if let itemImageUIDs = model?.imageUIDs {
            
            self.imageURLs = itemImageUIDs.compactMap { URL(string: "\(Constants.API_BASE_URL)media/" + $0) }
        }
    }
    
    func convertURLsToImageSource() {
        
        self.imageSources.removeAll()
        for url in self.imageURLs {
            imageSources.append(SDWebImageSource(url: url,
                                                 placeholder: UIImage(named: Constants.Images.defaultItemImage)))
        }
    }
    
    func formatDateForDisplay() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormat.defaultFormat
        dateFormatter.locale = Locale(identifier:"ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: model!.date) else {
            return "날짜 표시 에러"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(convertedDate) {
            dateFormatter.dateFormat = "오늘 HH:mm"
            return dateFormatter.string(from: convertedDate)
        } else if calendar.isDateInYesterday(convertedDate) {
            dateFormatter.dateFormat = "어제 HH:mm"
            return dateFormatter.string(from: convertedDate)
        } else {
            dateFormatter.dateFormat = "MM/dd HH:mm"
            return dateFormatter.string(from: convertedDate)
        }
    }
}

