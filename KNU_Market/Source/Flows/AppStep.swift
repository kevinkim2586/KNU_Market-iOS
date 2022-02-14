//
//  AppStep.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import RxFlow
import UIKit

enum AppStep: Step {
    
    //MARK: - Global
    
    case dismiss
    case popViewController
    case popViewControllerWithDelay(seconds: Double)
    case popToRootViewController
    case safariViewIsRequired(url: URL)
    
    
    //MARK: - Global - Authorization Related
    
    case unauthorized
    case unexpectedError
    
    //MARK: - Global - Alert Methods
    
    case alertIsRequired(type: AlertMessageType, title: String = "", message: String = "")
    
    
    //MARK: - Initial (Needed When App is Launched)
    
    case mainIsRequired
    case loginIsRequired
    
    
    //MARK: - Login

    
    //MARK: - Register
    
    case registerIsRequired
    case idInputIsCompleted
    case passwordInputIsCompleted
    case nicknameInputIsCompleted
    case emailInputIsCompleted
    
    //MARK: - Post
    
    case welcomeIndicatorRequired(nickname: String)
    case postListIsRequired
    case postIsPicked(postUid: String, isFromChatVC: Bool)
    case uploadPostIsRequired
    case uploadPostIsCompleted
    case perPersonPricePopupIsRequired(model: PerPersonPriceModel, preferredContentSize: CGSize, sourceView: UIView, delegateController: PostViewController)
    case editPostIsRequired(editModel: EditPostModel)

    //MARK: - Chat
    
    case chatListIsRequired
    case chatIsPicked(roomUid: String, chatRoomTitle: String, postUploaderUid: String, isFirstEntrance: Bool, isFromChatVC: Bool = false)
    case chatMemberListIsRequired(roomInfo: RoomInfo?, postUploaderUid: String)       // PanModal 사용
    case sendImageOptionsIsRequired     // 채팅방 내 "앨범" 또는 "카메라"에서 사진 선택
    case imageViewIsRequired(url: URL, heroID: String)            // 채팅방 내 사진 탭 했을 때 확대s
    
    
    
    
    
    
    
    //MARK: - My Page
    
    case myPageIsRequired
    case myPostsIsRequired
    case accountManagementIsRequired
    case verificationOptionIsRequired
    case inquiryIsRequired
    case termsAndConditionIsRequired
    case privacyTermsIsRequired
    case developerInfoIsRequired
    
    //MARK: - Account Management
    
    case changeIdIsRequired
    case changeNicknameIsRequired
    case changePasswordIsRequired
    case changeEmailIsRequired
    case logOutIsRequired
    case unRegisterIsRequired
    case openSystemSettingsIsRequired
    
    //MARK: - Verification
    
    case studentIdGuideIsRequired
    case studentIdVerificationIsRequired
    case emailVerificationIsRequired
    case checkUserEmailGuideIsRequired(email: String)
    case userVerificationIsCompleted
    
    //MARK: - Popup
    
    case popUpIsRequired(model: PopupModel)
    
    //MARK: - Unregister
    
    case readingFirstPrecautionsIsRequired
    case readingSecondPrecautionsIsRequired
    case passwordForUnregisterIsRequired(previousVCType: UnregisterStepType)
    case inputSuggestionForUnregisterIsRequired
    case kakaoHelpChannelLinkIsRequired
    case unregisterIsCompleted
    
    //MARK: - Inquiry (크누마켓팀과 대화하기)
    

    
    
    //MARK: - Report
    
    case reportIsRequired(userToReport: String, postUid: String?)
    case reportIsCompleted
}
