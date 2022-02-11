//
//  MyPostsFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/11.
//

import Foundation
import RxSwift
import RxFlow

class MyPostsFlow: Flow {
    
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: MyPostsViewController
    
    init(services: AppServices) {
        self.services = services
        
        let reactor = MyPostsViewReactor(postService: services.postService)
        let vc = MyPostsViewController(reactor: reactor)
        self.rootViewController = vc
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ MyPostsFlow step: \(step)")
        switch step {
        case .myPostsIsRequired:
            return navigateToMyPostsView()
            
        case .postIsPicked(let postUId, let isFromChatVC):
            return navigateToPostDetail(postUid: postUId, isFromChatVC: isFromChatVC)
            
        case .editPostIsRequired(let editModel):
            return navigateToEditPostVC(with: editModel)
            
        case let .chatIsPicked(roomUid, chatRoomTitle, postUploaderUid, isFirstEntrance, isFromChatVC):
            
            if isFromChatVC {
                self.rootViewController.navigationController?.popViewController(animated: true)
                return .none
            } else {
                return navigateToChat(
                    roomUid: roomUid,
                    roomTitle: chatRoomTitle,
                    postUploaderUid: postUploaderUid,
                    isFirstEntrance: isFirstEntrance
                )
            }
            
        case let .perPersonPricePopupIsRequired(model, preferredContentSize, sourceView, delegateController):
            return presentPerPersonPricePopupVC(
                model: model,
                preferredContentSize: preferredContentSize,
                sourceView: sourceView,
                delegateController: delegateController
            )
            
        default:
            return .none
        }
    }
}

extension MyPostsFlow {
    
    private func navigateToMyPostsView() -> FlowContributors {
        rootViewController.hidesBottomBarWhenPushed = true
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController.reactor!)
        )
    }
    
    private func navigateToPostDetail(postUid: String, isFromChatVC: Bool) -> FlowContributors {
        
        let reactor = PostViewReactor(
            pageId: postUid,
            isFromChatVC: isFromChatVC,
            postService: services.postService,
            chatService: services.chatService,
            sharingService: services.sharingService,
            userDefaultsService: services.userDefaultsGenericService
        )
        
        let postVC = PostViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(postVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: postVC, withNextStepper: reactor))
    }
    
    private func presentPerPersonPricePopupVC(
        model: PerPersonPriceModel,
        preferredContentSize: CGSize,
        sourceView: UIView,
        delegateController: PostViewController
    ) -> FlowContributors {
       
        let vc = PerPersonPriceInfoViewController(
            productPrice: model.productPrice,
            shippingFee: model.shippingFee,
            totalPrice: model.totalPrice,
            totalGatheringPeople: model.totalGatheringPeople,
            perPersonPrice: model.perPersonPrice
        )
        
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = preferredContentSize
        
        let popOver: UIPopoverPresentationController = vc.popoverPresentationController!
        popOver.delegate = delegateController
        popOver.sourceView = sourceView
        
        self.rootViewController.present(vc, animated: true)
        
        return .none
    }
    
    private func navigateToEditPostVC(with model: EditPostModel) -> FlowContributors {
        
        let reactor = UploadPostReactor(
            postService: services.postService,
            mediaService: services.mediaService,
            editModel: model
        )
        let uploadVC = UploadPostViewController(reactor: reactor)
        self.rootViewController.navigationController?.pushViewController(uploadVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: uploadVC, withNextStepper: reactor))
    }
    
    private func navigateToChat(
        roomUid: String,
        roomTitle: String,
        postUploaderUid: String,
        isFirstEntrance: Bool
    ) -> FlowContributors {
        
        let chatVM = ChatViewModel(room: roomUid, isFirstEntrance: isFirstEntrance)
        
        let chatVC = ChatViewController(viewModel: chatVM)
        chatVC.roomUID = roomUid
        chatVC.chatRoomTitle = roomTitle
        chatVC.postUploaderUID = postUploaderUid
        chatVC.isFirstEntrance = isFirstEntrance
        chatVC.hidesBottomBarWhenPushed = true
        
        self.rootViewController.navigationController?.pushViewController(chatVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatVC,
            withNextStepper: chatVM)
        )
    }
}
