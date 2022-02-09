//
//  MyPageFlo.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import Then
import RxFlow
import UIKit

class MyPageFlow: Flow {

    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    init(services: AppServices) {
        self.services = services
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .myPageIsRequired:
            return navigateToMyPage()
            
        case .myPostsIsRequired:
            return navigateToMyPostsLists()
            
        case .accountManagementIsRequired:
            return navigateToAccountManagement()
            
        case .verificationOptionIsRequired:
            return navigateToUserVerification()
            
        case .inquiryIsRequired:
            return navigateToInquiry()
            
        case .termsAndConditionIsRequired:
            return presentTermsAndConditionsView()
            
        case .privacyTermsIsRequired:
            return presentPrivacyTermsView()
            
        case .developerInfoIsRequired:
            return navigateToDeveloperInformation()
            
        default:
            return .none
        }
    }
}

extension MyPageFlow {
    
    private func navigateToMyPage() -> FlowContributors {
        
        let myPageReactor = MyPageViewReactor(
            userService: services.userService,
            mediaService: services.mediaService,
            userDefaultsGenericService: services.userDefaultsGenericService
        )
        
        let myPageVC = MyPageViewController(reactor: myPageReactor)
        
        self.rootViewController.pushViewController(myPageVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: myPageVC,
            withNextStepper: myPageReactor)
        )
    }
    
    private func navigateToMyPostsLists() -> FlowContributors {
        let reactor = MyPostsViewReactor(postService: services.postService)
        
        let myPostsVC = MyPostsViewController(reactor: reactor)
        myPostsVC.hidesBottomBarWhenPushed = true
        
        self.rootViewController.pushViewController(myPostsVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: myPostsVC,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToAccountManagement() -> FlowContributors {
       
        let accountManagementFlow = AccountManagementFlow(services: services)
        
        Flows.use(accountManagementFlow, when: .created) { [unowned self] root in
            root.hidesBottomBarWhenPushed = true
            self.rootViewController.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: accountManagementFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.accountManagementIsRequired))
        )
    }
    
    private func navigateToUserVerification() -> FlowContributors {
        
        let verificationFlow = VerificationFlow(services: services)
        
        Flows.use(verificationFlow, when: .created) { [unowned self] root in
            root.hidesBottomBarWhenPushed = true
            self.rootViewController.pushViewController(root, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: verificationFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.verificationOptionIsRequired))
        )
    }
    
    private func navigateToInquiry() -> FlowContributors {
        
        let reactor = SendUsMessageReactor(myPageService: self.services.myPageService)
        
        let vc = SendUsMessageViewController(reactor: reactor)
        vc.hidesBottomBarWhenPushed = true
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func presentTermsAndConditionsView() -> FlowContributors {
        let url = URL(string: K.URL.termsAndConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
    
    private func presentPrivacyTermsView() -> FlowContributors {
        let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
    
    private func navigateToDeveloperInformation() -> FlowContributors {
        let vc = DeveloperInformationViewController()
        vc.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .none
    }
}
