//
//  MyPageViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RxFlow
import ReactorKit
import Differentiator

final class MyPageViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
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
     
        // Navigation
        case cellSelected(IndexPath)
        case settingsSelected
    }
    
    enum Mutation {
        case setUserProfile(LoadProfileResponseModel)
        case updateProfileImageUrl(String?)
        case removeProfileImageUrl(Bool)
        case setAlertMessage(String)
    }
    
    struct State {
        
        var profileImageUrl: String?
        var displayName: String = "-"
        var username: String = "-"
        var isReportChecked: Bool = false
        var isVerified: Bool = false
        var alertMessage: String?

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
    
    init(
        userService: UserServiceType,
        mediaService: MediaServiceType,
        userDefaultsGenericService: UserDefaultsGenericServiceType
    ) {
        self.userService = userService
        self.mediaService = mediaService
        self.userDefaultsGenericService = userDefaultsGenericService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .viewDidLoad:
            return loadUserProfile()
            
        case .viewWillAppear:
            NotificationCenterService.configureChatTabBadgeCount.post()
            return Observable.empty()
            
        case .viewDidAppear:
            return loadUserProfile()
            
        case .updateProfileImage(let image):
            
            guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                return Observable.just(Mutation.setAlertMessage("이미지 업로드에 실패했습니다. 잠시 후 다시 시도해주세요. 🥲"))
            }
            
            return self.userService.updateUserInfo(
                type: .profileImage,
                updatedInfo: nil,
                profileImageData: imageData
            )
                .asObservable()
                .map { result in
                    switch result {
                    case .success(let model):
                        return Mutation.updateProfileImageUrl(model.profileUrl)
                    case .error(let error):
                        return Mutation.setAlertMessage(error.errorDescription)
                    }
                }
            
        case .removeProfileImage:
            return self.userService.updateUserInfo(type: .profileImage, updatedInfo: nil, profileImageData: nil)
                .asObservable()
                .map { result in
                    switch result {
                    case .success:
                        return Mutation.removeProfileImageUrl(true)
                    case .error(let error):
                        return Mutation.setAlertMessage(error.errorDescription)
                    }
                }
            
        case .cellSelected(let indexPath):
            
            switch indexPath.section {
                
            case 0:
                switch indexPath.row {
                case 0:
                    self.steps.accept(AppStep.myPostsIsRequired)
                    return .empty()
                case 1:
                    self.steps.accept(AppStep.accountManagementIsRequired)
                    return .empty()
                case 2:
                    self.steps.accept(AppStep.verificationOptionIsRequired)
                    return .empty()
                default: return .empty()
                }
                
            case 1:
                switch indexPath.row {
                case 0:
                    self.steps.accept(AppStep.inquiryIsRequired)
                    return .empty()
                case 1:
                    self.steps.accept(AppStep.termsAndConditionIsRequired)
                    return .empty()
                case 2:
                    self.steps.accept(AppStep.privacyTermsIsRequired)
                    return .empty()
                case 3:
                    self.steps.accept(AppStep.developerInfoIsRequired)
                    return .empty()
                    
                default: return .empty()
                }
            default: return .empty()
            }
            
        case .settingsSelected:
            self.steps.accept(AppStep.accountManagementIsRequired)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.alertMessage = nil

        switch mutation {
        case .setUserProfile(let loadProfileUserModel):
            state.displayName = loadProfileUserModel.displayName
            state.username = loadProfileUserModel.username
            
            state.profileImageUrl = loadProfileUserModel.profileUrl
               
            state.isVerified = loadProfileUserModel.userRoleGroup.userRoleCode == UserRoleGroupType.common.rawValue ? true : false
         
//            state.isReportChecked = !loadProfileUserModel.isReportChecked
//            state.myPageSectionModels[1].items[0].isNotificationBadgeHidden = !loadProfileUserModel.isReportChecked
            
        case .updateProfileImageUrl(let imageUrl):
            state.alertMessage = "프로필 이미지 변경 성공 🎉"
            state.profileImageUrl = imageUrl
            
        case .removeProfileImageUrl:
            state.alertMessage = "프로필 사진 제거 성공 🎉"
            state.profileImageUrl = nil

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
                    return Mutation.setUserProfile(loadProfileModel)
                    
                case .error(let error):
                    return Mutation.setAlertMessage(error.errorDescription)
                }
            }
    }
}
