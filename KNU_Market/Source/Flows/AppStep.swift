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
    case popToRootViewController
    
    
    //MARK: - Global - Authorization Related
    
    case unauthorized
    case unexpectedError
    
    
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
    case chatMemberListIsRequired
    
    
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
