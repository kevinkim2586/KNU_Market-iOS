//
//  InquiryFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/14.
//

import Foundation
import RxFlow

class InquiryFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: SendUsMessageViewController
    
    init(services: AppServices) {
        self.services = services
        
        let reactor = SendUsMessageReactor(myPageService: services.myPageService)
        let vc = SendUsMessageViewController(reactor: reactor)
        
        vc.hidesBottomBarWhenPushed = true
        self.rootViewController = vc
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ InquiryFlow step: \(step)")
        switch step {
        case .inquiryIsRequired:
            return navigateToSendUsMessageView()
            
        case .inquiryListIsRequired:
            return navigateToInquiryList()
            
        case let .detailMessageIsRequired(title, content, answer, uid):
            return navigateToDetailMessageView(title: title, content: content, answer: answer, uid: uid)
            
        case .popViewControllerWithDelay(let seconds):
            
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.rootViewController.navigationController?.popViewController(animated: true)
            }
            return .none
            
        case .inquiryIsRequiredAgain:
            
            self.rootViewController.navigationController?.popViewController(animated: true)
            self.rootViewController.navigationController?.popViewController(animated: true)
            return .none
            
        default:
            return .none
        }
    }
}

extension InquiryFlow {
    
    private func navigateToSendUsMessageView() -> FlowContributors {
        
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func navigateToInquiryList() -> FlowContributors {
        
        let vc = InquiryListViewController()
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: vc)
        )
    }
    
    private func navigateToDetailMessageView(title: String, content: String, answer: String?, uid: Int) -> FlowContributors {
        
        let reactor = DetailMessageViewReactor(
            title: title,
            content: content,
            answer: answer,
            uid: uid,
            myPageService: services.myPageService
        )
        let vc = DetailMessageViewController(reactor: reactor)
        
        self.rootViewController.navigationController?.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
}
