//
//  PopupFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import RxFlow

#warning("팝업 테스트해보기")
class PopupFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: PostListViewController
    
    init(services: AppServices) {
        self.services = services
        
        let reactor = PostListViewReactor(
            postService: services.postService,
            chatListService: services.chatListService,
            userService: services.userService,
            popupService: services.popupService,
            bannerService: services.bannerService,
            userDefaultsGenericService: services.userDefaultsGenericService,
            userNotificationService: services.userNotificationService
        )
        
        let popupVC = PostListViewController(reactor: reactor)
        self.rootViewController = popupVC
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .popUpIsRequired(let popupModel):
            return presentPopup(with: popupModel)
            
        default:
            return .none
        }
    }
}

extension PopupFlow {
    
    private func presentPopup(with model: PopupModel) -> FlowContributors {
        
        let reactor = PopupReactor(
            popupUid: model.popupUid,
            mediaUid: model.mediaUid,
            landingUrlString: model.landingUrl,
            popupService: services.popupService
        )
        
        let popupVC = PopupViewController(reactor: reactor)
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        
        self.rootViewController.present(popupVC, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: popupVC,
            withNextStepper: reactor)
        )
    }
}
