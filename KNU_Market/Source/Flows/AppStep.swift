//
//  AppStep.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import RxFlow

enum AppStep: Step {
    
    //MARK: - Global
    
    case dismiss
    case popViewController
    case popToRootViewController
    
    case mainIsRequired
    
    
    //MARK: - Login
    
    case loginIsRequired
    
    //MARK: - Register
    
    
    //MARK: - Post
    
    case postListIsRequired
    case uploadPostIsRequired
    case postIsRequired(postUid: String, isFromChatVC: Bool)
    
    
    //MARK: - Chat
    
    case chatListIsRequired
    
    
    //MARK: - My Page
    
    case myPageIsRequired
    case myPostsIsRequired
    case settingsIsRequired
    case verificationIsRequired
    case inquiryIsRequired
    case termsAndConditionIsRequired
    case privacyTermsIsRequired
    
    //MARK: - Settings
    
    case changeIdIsRequired
    case changeNicknameIsRequired
    case changePasswordIsRequired
    case changeEmailIsRequired
    case logOutIsRequired
    case unRegisterIsRequired
    
    //MARK: - Unregister
    
    
    
    //MARK: - Inquiry (크누마켓팀과 대화하기)
    
    
    
}
