//
//  MyPageViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import Differentiator

final class MyPageViewReactor: Reactor {
  
    let initialState: State
    let userService: UserServiceType
    let mediaService: MediaServiceType
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    enum Action {
        case viewDidLoad
        case viewWillAppear
        case viewDidAppear
        case updateProfileImage(UIImage)               // User selected image
        case removeProfileImage
        case cellSelected(IndexPath)
    }
    
    enum Mutation {
        case setUserProfile(Bool? = nil, String)       // isReportChecked, profileImageUid
        case updateProfileImageUid(String)             // profileImageUid
        case setProfileImageUidToDefault
        case setSelectedCellIndexPath(IndexPath)
        case setAlertMessage(String)
    }
    
    struct State {
        
        var profileImageUid: String = "default"
        var userNickname: String
        var userId: String
        
        var isReportChecked: Bool = false
        var isVerified: Bool
        
        var selectedCellIndexPath: IndexPath?
        
        var alertMessage: String?
        
        
        var profileImageUrlString: String {
            return K.MEDIA_REQUEST_URL + "\(profileImageUid)"
        }
        
        var myPageSectionModels = [
            MyPageSectionModel(header: "사용자 설정", items: [
                MyPageCellData(leftImageName: "tray.full", title: "내가 올린 글"),
                MyPageCellData(leftImageName: "gear", title: "설정"),
                MyPageCellData(leftImageName: "checkmark.circle", title: "웹메일/학생증 인증")
            ]),
            MyPageSectionModel(header: "기타", items: [
                MyPageCellData(leftImageName: "talk_with_team_icon", title: "크누마켓팀과 대화하기"),
                MyPageCellData(leftImageName: "doc.text", title: "서비스 이용약관"),
                MyPageCellData(leftImageName: "hand.raised", title: "개인정보 처리방침"),
                MyPageCellData(leftImageName: "info.circle", title: "개발자 정보")
            ])
        ]
    }
    
    init(userService: UserServiceType, mediaService: MediaServiceType, userDefaultsGenericService: UserDefaultsGenericServiceType) {
        
        self.userService = userService
        self.mediaService = mediaService
        self.userDefaultsGenericService = userDefaultsGenericService
        
        guard
            let nickname: String    = userDefaultsGenericService.get(key: UserDefaults.Keys.nickname),
            let userId: String      = userDefaultsGenericService.get(key: UserDefaults.Keys.userID),
            let isVerified: Bool    = userDefaultsGenericService.get(key: UserDefaults.Keys.hasVerifiedEmail)
        else {
            self.initialState = State(
                userNickname: "-",
                userId: "-",
                isVerified: false
            )
            return
        }
        
        self.initialState = State(
            userNickname: nickname,
            userId: userId,
            isVerified: isVerified
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .viewDidLoad:
            return loadUserProfile()

        case .viewWillAppear:
            NotificationCenter.default.post(name: .getBadgeValue, object: nil)
            return Observable.empty()
            
        case .viewDidAppear:
            return loadUserProfile()
            
        case .updateProfileImage(let image):
            
            guard let imageData = image.jpegData(compressionQuality: 0.9) else {
                return Observable.just(Mutation.setAlertMessage("이미지 업로드에 실패했습니다. 잠시 후 다시 시도해주세요. 🥲"))
            }
            
            return self.mediaService.uploadImage(with: imageData)
                .asObservable()
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let uploadImageResponseModel):
                        
                        let imageUid = uploadImageResponseModel.uid             // 서버 이미지 업로드 성공 시 날아오는 신규 image uid
                    
                        return self.userService.updateUserInfo(type: .profileImage, updatedInfo: imageUid)
                            .asObservable()
                            .map { result in
                                switch result {
                                case .success:
                                    return Mutation.updateProfileImageUid(imageUid)
                                case .error(let error):
                                    return Mutation.setAlertMessage(error.errorDescription)
                                }
                            }
                        
                    case .error(let error):
                        return Observable.just(Mutation.setAlertMessage(error.errorDescription))
                    }
                }
            
        case .removeProfileImage:
            return self.userService.updateUserInfo(type: .profileImage, updatedInfo: "default")
                .asObservable()
                .map { result in
                    switch result {
                    case .success:
                        return Mutation.setProfileImageUidToDefault
                    case .error(let error):
                        return Mutation.setAlertMessage(error.errorDescription)
                    }
                }
            
        case .cellSelected(let indexPath):
            return Observable.just(Mutation.setSelectedCellIndexPath(indexPath))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil
        state.selectedCellIndexPath = nil
        
        switch mutation {
        case .setUserProfile(let isReportChecked, let profileImageUid):
            state.profileImageUid = profileImageUid
            if let isReportChecked = isReportChecked {
                state.isReportChecked = isReportChecked
                state.myPageSectionModels[1].items[0].isNotificationBadgeHidden = isReportChecked
            }

        case .updateProfileImageUid(let profileImageUid):
            state.alertMessage = "프로필 이미지 변경 성공 🎉"
            state.profileImageUid = profileImageUid
            
        case .setProfileImageUidToDefault:
            state.alertMessage = "프로필 사진 제거 성공 🎉"
            state.profileImageUid = "default"
            
        case .setSelectedCellIndexPath(let indexPath):
            state.selectedCellIndexPath = indexPath
            
        case .setAlertMessage(let alertMessage):
            state.alertMessage = alertMessage
        }
        return state
    }
}

extension MyPageViewReactor {
    

    private func loadUserProfile() -> Observable<Mutation> {
        
        return self.userService.loadUserProfile()
            .asObservable()
            .map { result in
                switch result {
                case .success(let loadProfileModel):
                    let isReportChecked = !loadProfileModel.isReportChecked
                    let profileImageUid = loadProfileModel.profileImageUid == "default"
                    ? "default"
                    : loadProfileModel.profileImageUid
                    return Mutation.setUserProfile(isReportChecked, profileImageUid)
                    
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription)
                }
            }
    }
}
