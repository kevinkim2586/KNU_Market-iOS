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
    
    
    
    
    //MARK: - Initial
    
    case mainIsRequired
    case loginIsRequired
    
    
    //MARK: - Login
    

    
    //MARK: - Register
    
    
    //MARK: - Post
    
    case welcomeIndicatorRequired(nickname: String)
    case postListIsRequired
    case postIsPicked(postUid: String, isFromChatVC: Bool)
    case uploadPostIsRequired
    case perPersonPricePopupIsRequired(model: PerPersonPriceModel, preferredContentSize: CGSize, sourceView: UIView, delegateController: PostViewController)
    case editPostIsRequired(editModel: EditPostModel)

    
    //MARK: - Chat
    
    case chatListIsRequired
    case chatIsPicked(roomUid: String, chatRoomTitle: String, postUploaderUid: String, isFirstEntrance: Bool, isFromChatVC: Bool = false)
    
    
    //MARK: - My Page
    
    case myPageIsRequired
    case myPostsIsRequired
    case accountManagementIsRequired
    case verificationIsRequired
    case inquiryIsRequired
    case termsAndConditionIsRequired
    case privacyTermsIsRequired
    case developerInfoIsRequired
    
    //MARK: - Settings
    
    case changeIdIsRequired
    case changeNicknameIsRequired
    case changePasswordIsRequired
    case changeEmailIsRequired
    case logOutIsRequired
    case unRegisterIsRequired
    case readingsPrecautionsIsRequired
    
    //MARK: - Popup
    
    case popUpIsRequired(model: PopupModel)
    
    //MARK: - Unregister
    
    
    
    //MARK: - Inquiry (크누마켓팀과 대화하기)
    

    
    
    
}
