import Foundation
import UIKit

protocol HomeViewModelDelegate: AnyObject {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
    
    func didFetchItemList()
    func failedFetchingItemList(errorMessage: String, error: NetworkError)
    
    func didFetchLatestPopup(model: PopupModel)
    func failedFetchingLatestPopup(with error: NetworkError)
    
    func failedFetchingRoomPIDInfo(with error: NetworkError)
}

extension HomeViewModelDelegate {
    func didFetchUserProfileInfo() {}
    func failedFetchingUserProfileInfo(with error: NetworkError) {}
    func didFetchUserProfileImage() {}
    func failedFetchingRoomPIDInfo(with error: NetworkError) {}
    func didFetchLatestPopup(model: PopupModel) {}
    func failedFetchingLatestPopup(with error: NetworkError) {}
}

class HomeViewModel {
    
    private var itemManager: ItemManager?
    private var chatManager: ChatManager?
    private var userManager: UserManager?
    private var popupManager: PopupManager?
    
    weak var delegate: HomeViewModelDelegate?
    
    var itemList: [ItemListModel] = []
    
    var isFetchingData: Bool = false
    var index: Int = 1
    
    //MARK: - Initialization
    init(itemManager: ItemManager) {
        self.itemManager = itemManager
    }
    
    init(itemManager: ItemManager, chatManager: ChatManager, userManager: UserManager, popupManager: PopupManager?) {
        self.itemManager = itemManager
        self.chatManager = chatManager
        self.userManager = userManager
        self.popupManager = popupManager
    }
    
    //MARK: - 공구글 불러오기
    func fetchItemList(fetchCurrentUsers: Bool = false) {
        
        isFetchingData = true
        
        itemManager?.fetchItemList(
            at: self.index,
            fetchCurrentUsers: fetchCurrentUsers,
            postFilterOption: User.shared.postFilterOption
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedModel):
                
                if fetchedModel.isEmpty {
                    self.delegate?.didFetchItemList()
                    return
                }
                
                self.index += 1
                
                for model in fetchedModel {
                    if User.shared.bannedPostUploaders.contains(model.userInfo?.userUID ?? "") { continue }
                    if fetchCurrentUsers {
                        User.shared.userUploadedRoomPIDs.append(model.uuid)
                    }
                    self.itemList.append(model)
                }
          
                self.isFetchingData = false
                self.delegate?.didFetchItemList()
                
            case .failure(let error):
                let errorMessage = error == .E601 ? "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!" : "오류가 발생했습니다!\n잠시 후 다시 시도해주세요."
                self.delegate?.failedFetchingItemList(errorMessage: errorMessage, error: error)
            }
        }
    }
    
    //MARK: - 사용자 프로필 정보 불러오기
    func loadUserProfile() {
        userManager?.loadUserProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_): self.delegate?.didFetchUserProfileInfo()
            case .failure(let error): self.delegate?.failedFetchingUserProfileInfo(with: error)
            }
        }
    }
    
    //MARK: - 내가 참여하고 있는 Room PID 배열 불러오기
    func fetchEnteredRoomInfo() {
        chatManager?.getResponseModel(
            function: .getRoom,
            method: .get,
            pid: nil,
            index: nil,
            expectedModel: [Room].self
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let chatRoom):
                chatRoom.forEach { User.shared.joinedChatRoomPIDs.append($0.uuid) }
            case .failure(let error):
                self.delegate?.failedFetchingRoomPIDInfo(with: error)
            }
        }
    }

    //MARK: - 글 정렬 기준 변경
    func changePostFilterOption() {
        if User.shared.postFilterOption == .showAll {
            User.shared.postFilterOption = .showGatheringFirst
        } else {
            User.shared.postFilterOption = .showAll
        }
        refreshTableView()
    }
    
    func fetchLatestPopup() {
        guard let popupManager = popupManager else { return }
        
        print("✏️ didUserSetTonotseepop: \(popupManager.didUserSetToNotSeePopupForADay)")
        print("✏️ didADayPass: \(popupManager.didADayPass)")
        
        // 24시간 보지 않기를 누른 적이 있는지와 24시간이 지났는지 판별
//        if popupManager.didUserSetToNotSeePopupForADay || popupManager.didADayPass {
//            print("❗️ will returm")
//            return }
//
        
        
        popupManager.fetchLatestPopup { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let popupModel):
                if popupManager.determineIfAlreadySeenPopup(uid: popupModel.popupUid) { return }
                self.delegate?.didFetchLatestPopup(model: popupModel)
            case .failure(let error):
                self.delegate?.failedFetchingLatestPopup(with: error)
            }
        }
    }
}

extension HomeViewModel {
    
    // 앱 최초 실행 시 로딩해야 할 메서드들 모음
    func loadInitialMethods() {
        fetchEnteredRoomInfo()
        loadUserProfile()
        fetchItemList()
        fetchLatestPopup()
    }
    
    func refreshTableView() {
        resetValues()
        fetchItemList()
        fetchEnteredRoomInfo()
    }
    
    func resetValues() {
        User.shared.joinedChatRoomPIDs.removeAll()
        User.shared.userUploadedRoomPIDs.removeAll()
        itemList.removeAll()
        isFetchingData = false
        index = 1
    }
    
    var filterActionTitle: String {
        return User.shared.postFilterOption == .showAll ? "'모집 중' 먼저보기" : "최신 순으로 보기"
    }
}
