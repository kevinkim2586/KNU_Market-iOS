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
    
    func didCancelMarkPostDone()
    func failedCancelMarkPostDone(with error: NetworkError)
    
    func didEnterChat(isFirstEntrance: Bool)
    func failedJoiningChat(with error: NetworkError)
    
    func didBlockUser()
    func didDetectURL(with string: NSMutableAttributedString)
    
    func failedLoadingData(with error: NetworkError)
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
        guard let model = model else { return 1 }
        if model.currentlyGatheredPeople < 1 { return 1 }
        else { return model.currentlyGatheredPeople }
    }
    
    var totalGatheringPeople: Int {
        return model?.totalGatheringPeople ?? 2
    }
    
    var location: String {
        let index = (model?.location ?? Location.listForCell.count - 1)
        guard index != Location.listForCell.count + 1 else {
            return Location.listForCell[Location.listForCell.count - 1]
        }
        return Location.listForCell[index - 1]
    }
    
    var date: String {
        return getFormattedDateStringToDisplayTodayAndYesterday()
    }
    
    var viewCount: String {
        guard let model = model else { return "조회 -" }
        return "조회 \(model.viewCount)"
    }
    
    // 사용자가 올린 공구인지 여부
    var postIsUserUploaded: Bool {
        return model?.nickname == User.shared.nickname
    }

    // 이미 참여하고 있는 공구인지
    var userAlreadyJoinedPost: Bool {
        return User.shared.joinedChatRoomPIDs.contains(pageID ?? "") ? true: false
    }
    
    // 인원이 다 찼는지 여부
    var isFull: Bool {
        return model?.isFull ?? true
    }
    
    // 공구 마감 여부
    var isCompletelyDone: Bool {
        return model?.isCompletelyDone ?? true
    }
    
    // 모집 여부
    var isGathering: Bool {
        return isCompletelyDone ? false : true
    }
    
    var modelForEdit: EditPostModel {
        let editPostModel = EditPostModel(
            title: model?.title ?? "",
            imageURLs: imageURLs,
            imageUIDs: model?.imageUIDs,
            totalGatheringPeople: totalGatheringPeople,
            currentlyGatheredPeople: currentlyGatheredPeople,
            location: model?.location ?? 0,
            itemDetail: model?.itemDetail ?? "",
            pageUID: pageID ?? ""
        )
        return editPostModel
    }
    
    var userIncludedURL: URL?
    
    
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
                NotificationCenter.default.post(
                    name: .updateItemList,
                    object: nil
                )
            case .failure(let error):
                self.delegate?.failedMarkingPostDone(with: error)
            }
        }
    }
    
    //MARK: - 공구글 완료 표시 해제하기
    func cancelMarkPostDone(for uid: String) {
        
        let model = UpdatePostRequestDTO(title: self.model?.title ?? "",
                                         location: self.model?.location ?? 0,
                                         detail: self.model?.itemDetail ?? "",
                                         imageUIDs: self.model?.imageUIDs ?? [],
                                         totalGatheringPeople: self.totalGatheringPeople,
                                         currentlyGatheredPeople: self.currentlyGatheredPeople,
                                         isCompletelyDone: false)
        
        ItemManager.shared.updatePost(uid: uid, with: model) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                
                self.delegate?.didCancelMarkPostDone()
                NotificationCenter.default.post(name: .updateItemList, object: nil)
                
            case .failure(let error):
                
                self.delegate?.failedCancelMarkPostDone(with: error)
            }
        }
        
    }
    
    //MARK: - 채팅방 참가하기
    func joinPost() {
        
        if currentlyGatheredPeople == totalGatheringPeople && !postIsUserUploaded && !userAlreadyJoinedPost {
            delegate?.failedJoiningChat(with: .E001)
            return
        }

       print("✏️ pageID: \(self.pageID ?? "에러")")
        
        ChatManager.shared.changeJoinStatus(function: .join,
                                            pid: self.pageID ?? "error") { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.delegate?.didEnterChat(isFirstEntrance: true)
            case .failure(let error):
                
                print("❗️ ItemViewModel - joinPost error: \(error)")
                
                switch error {
                    // 이미 참여하고 있는 채팅방이면 성공은 성공임. 그러나 기존의 메시지를 불러와야함
                case .E108:
                    self.delegate?.didEnterChat(isFirstEntrance: false)
                    NotificationCenter.default.post(
                        name: .updateItemList,
                        object: nil
                    )
                default:
                    self.delegate?.failedJoiningChat(with: error)
                }
            }
        }
    }
    
    //MARK: - 내가 참여하고 있는 Room PID 배열 불러오기
    func fetchEnteredRoomInfo() {
        
        ChatManager.shared.getResponseModel(function: .getRoom,
                                            method: .get,
                                            pid: nil,
                                            index: nil,
                                            expectedModel: [Room].self) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let chatRoom):
                
                chatRoom.forEach { chat in
                    User.shared.joinedChatRoomPIDs.append(chat.uuid)
                }
                
            case .failure(let error):
                self.delegate?.failedLoadingData(with: error)
            }
        }
    }
    
    func blockUser(userUID: String) {
        User.shared.bannedPostUploaders.append(userUID)
        self.delegate?.didBlockUser()
        NotificationCenter.default.post(
            name: .updateItemList,
            object: nil
        )
    }
    
    func detectURL() {
        
        var detectedURLString: String?
        
        guard let itemDetail = model?.itemDetail else { return }
        
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
        let matches = detector.matches(
            in: itemDetail,
            options: [],
            range: NSRange(location: 0, length: itemDetail.utf16.count)
        )

        for match in matches {
            guard let range = Range(match.range, in: itemDetail) else { continue }
            let url = itemDetail[range]
            detectedURLString = String(url)
        }
        
        guard
            let urlString = detectedURLString,
            let url = URL(string: urlString)
        else { return }
    
        userIncludedURL = url
        
        let attributedString = NSMutableAttributedString(string: itemDetail)
        
        if let range: Range<String.Index> = itemDetail.range(of: "http") {
            let index: Int = itemDetail.distance(
                from: itemDetail.startIndex,
                to: range.lowerBound
            )
            
            attributedString.addAttribute(
                .link,
                value: urlString,
                range: NSRange(location: index, length: urlString.count)
            )
        }
        delegate?.didDetectURL(with: attributedString)
    }
}

//MARK: - Conversion Methods

extension ItemViewModel {
    
    func convertUIDsToURL() {
        imageURLs.removeAll()
        if let itemImageUIDs = model?.imageUIDs {
            imageURLs = itemImageUIDs.compactMap { URL(string: "\(K.API_BASE_URL)media/" + $0) }
        }
    }
    
    func convertURLsToImageSource() {
        imageSources.removeAll()
        for url in self.imageURLs {
            imageSources.append(SDWebImageSource(
                url: url,
                placeholder: UIImage(named: K.Images.defaultItemImage))
            )
        }
    }
    
    func getFormattedDateStringToDisplayTodayAndYesterday() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = K.DateFormat.defaultFormat
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

