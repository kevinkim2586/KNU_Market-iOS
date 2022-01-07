import UIKit
import RxSwift

protocol PostListViewModelDelegate: AnyObject {
    
    func didFetchUserProfileInfo()
    func failedFetchingUserProfileInfo(with error: NetworkError)
    
    func didFetchPostList()
    func failedFetchingPostList(errorMessage: String, error: NetworkError)
    
    // 팝업 가져오기
    func didFetchLatestPopup(model: PopupModel)
    func failedFetchingLatestPopup(with error: NetworkError)
    
    func failedFetchingRoomPIDInfo(with error: NetworkError)
}

extension PostListViewModelDelegate {
    func didFetchUserProfileInfo() {}
    func failedFetchingUserProfileInfo(with error: NetworkError) {}
    func didFetchUserProfileImage() {}
    func failedFetchingRoomPIDInfo(with error: NetworkError) {}
    func didFetchLatestPopup(model: PopupModel) {}
    func failedFetchingLatestPopup(with error: NetworkError) {}
}

class PostListViewModel {
    
    private var postManager: PostManager?
    private var chatManager: ChatManager?
    private var userManager: UserManager?
    private var popupService: PopupServiceType
    
    var disposeBag = DisposeBag()
    
    weak var delegate: PostListViewModelDelegate?
    
    var postList: [PostListModel] = []
    
    var isFetchingData: Bool = false
    var index: Int = 1
    
    //MARK: - Initialization
    init(postManager: PostManager, chatManager: ChatManager, userManager: UserManager, popupService: PopupServiceType) {
        self.postManager = postManager
        self.chatManager = chatManager
        self.userManager = userManager
        self.popupService = popupService
    }
    
    //MARK: - 공구글 불러오기
    func fetchPostList(fetchCurrentUsers: Bool = false) {
        
        isFetchingData = true
        
        postManager?.fetchPostList(
            at: self.index,
            fetchCurrentUsers: fetchCurrentUsers,
            postFilterOption: User.shared.postFilterOption
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedModel):
                
                if fetchedModel.isEmpty {
                    self.delegate?.didFetchPostList()
                    return
                }
                
                self.index += 1
                
                for model in fetchedModel {
                    if User.shared.bannedPostUploaders.contains(model.userInfo?.userUID ?? "") {
                        continue
                    }
                    self.postList.append(model)
                }
          
                self.isFetchingData = false
                self.delegate?.didFetchPostList()
                
            case .failure(let error):
                let errorMessage = error == .E601
                ? "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
                : "오류가 발생했습니다!\n잠시 후 다시 시도해주세요."
                self.delegate?.failedFetchingPostList(errorMessage: errorMessage, error: error)
            }
        }
    }
    
    //MARK: - 사용자 프로필 정보 불러오기
    func loadUserProfile() {
        userManager?.loadUserProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.delegate?.didFetchUserProfileInfo()
            case .failure(let error):
                self.delegate?.failedFetchingUserProfileInfo(with: error)
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
                
                UserDefaultsGenericService.shared.set(
                    key: UserDefaults.Keys.joinedChatRoomPIDs,
                    value: chatRoom.map { $0.uuid}
                )
            case .failure(let error):
                self.delegate?.failedFetchingRoomPIDInfo(with: error)
            }
        }
    }
    
    //MARK: - 팝업 가져오기
    func fetchLatestPopup() {
        
        if !popupService.shouldFetchPopup { return }
        
        popupService.fetchLatestPopup()
            .subscribe { [weak self] result in
                switch result {
                case .success(let networkResult):
                    switch networkResult {
                    case .success(let popupModel):
                        self?.delegate?.didFetchLatestPopup(model: popupModel)
                    case .error(let error):
                        self?.delegate?.failedFetchingLatestPopup(with: error)
                    }
                case .failure(_):
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    func changePostFilterOption() {
        if User.shared.postFilterOption == .showByRecentDate {
            User.shared.postFilterOption = .showGatheringFirst
        } else {
            User.shared.postFilterOption = .showByRecentDate
        }
        refreshTableView()
    }
    
    // 앱 최초 실행 시 로딩해야 할 메서드들 모음
    func loadInitialMethods() {
        fetchEnteredRoomInfo()
        loadUserProfile()
        fetchPostList()
        fetchLatestPopup()
    }
    
    func refreshTableView() {
        resetValues()
        fetchPostList()
        fetchEnteredRoomInfo()
    }
    
    func resetValues() {
        postList.removeAll()
        isFetchingData = false
        index = 1
    }
}


extension PostListViewModel {
    
    var filterActionTitle: String {
        return User.shared.postFilterOption == .showByRecentDate ? "'모집 중' 먼저보기" : "최신 순으로 보기"
    }
}
