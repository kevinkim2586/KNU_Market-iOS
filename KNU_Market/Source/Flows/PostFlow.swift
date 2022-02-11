//
//  PostFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.

import Then
import RxFlow
import UIKit
import RxSwift
import SPIndicator

class PostFlow: Flow {

    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController().then { _ in
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()      // 불투명한 Background
            appearance.shadowColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    init(services: AppServices) {
        self.services = services
    }
    
    func adapt(step: Step) -> Single<Step> {
        guard let step = step as? AppStep else { return .just(step) }
        
        switch step {
        case .uploadPostIsRequired:
            let isUserVerified: Bool = self.services.userDefaultsGenericService.get(key: UserDefaults.Keys.hasVerifiedEmail) ?? false
            return isUserVerified ? .just(step) : .just(AppStep.unauthorized)
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        print("✅ PostFlow step: \(step)")
        switch step {
        case .postListIsRequired:
            return navigateToPostList()
            
        case .postIsPicked(let postUid, let isFromChatVC):
            return navigateToPostDetail(postUid: postUid, isFromChatVC: isFromChatVC)
            
        case .uploadPostIsRequired:
            return navigateToUploadPostVC()
            
        case .uploadPostIsCompleted:
            self.rootViewController.popToRootViewController(animated: true)
            return .none
            
        case .welcomeIndicatorRequired(let nickname):
            return presentWelcomeIndicator(with: nickname)
            
        case let .perPersonPricePopupIsRequired(model, preferredContentSize, sourceView, delegateController):
            return presentPerPersonPricePopupVC(
                model: model,
                preferredContentSize: preferredContentSize,
                sourceView: sourceView,
                delegateController: delegateController
            )
            
        case let .editPostIsRequired(editModel):
            return navigateToEditPostVC(with: editModel)
            
        case let .chatIsPicked(roomUid, chatRoomTitle, postUploaderUid, isFirstEntrance, isFromChatVC):
            
            if isFromChatVC {
                self.rootViewController.popViewController(animated: true)
                return .none
            } else {
                return navigateToChat(
                    roomUid: roomUid,
                    roomTitle: chatRoomTitle,
                    postUploaderUid: postUploaderUid,
                    isFirstEntrance: isFirstEntrance
                )
            }
            
        case let .reportIsRequired(userToReport, postUid):
            return presentReportUserView(userToReport: userToReport, postUid: postUid)
            
        case .popViewController:
            self.rootViewController.popViewController(animated: true)
            return .none
            
        case .unauthorized:
            return presentUnauthorizedAlert()
            
        case .unexpectedError:
            return presentUnexpectedError()
            
        default:
            return .none
        }
    }
}

extension PostFlow {
    
    private func navigateToPostList() -> FlowContributors {
        
        let postListReactor = PostListViewReactor(
            postService: services.postService,
            chatListService: services.chatListService,
            userService: services.userService,
            popupService: services.popupService,
            bannerService: services.bannerService,
            userDefaultsGenericService: services.userDefaultsGenericService,
            userNotificationService: services.userNotificationService
        )
        let postListVC = PostListViewController(reactor: postListReactor)
        
        self.rootViewController.pushViewController(postListVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: postListVC,
            withNextStepper: postListReactor)
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
        self.rootViewController.pushViewController(postVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: postVC, withNextStepper: reactor))
    }
    
    private func navigateToUploadPostVC() -> FlowContributors {
        
        let reactor = UploadPostReactor(
            postService: services.postService,
            mediaService: services.mediaService
        )
        
        let uploadVC = UploadPostViewController(reactor: reactor)
        self.rootViewController.pushViewController(uploadVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: uploadVC, withNextStepper: reactor))
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
        
        self.rootViewController.pushViewController(uploadVC, animated: true)
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
        
        self.rootViewController.pushViewController(chatVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: chatVC,
            withNextStepper: chatVM)
        )
    }
    
    private func presentReportUserView(userToReport: String, postUid: String?) -> FlowContributors {
        
        let reportFlow = ReportFlow(
            reportService: self.services.reportService,
            userToReport: userToReport,
            postUid: postUid
        )
        
        Flows.use(reportFlow, when: .created) { [unowned self] rootVC in
            self.rootViewController.present(rootVC, animated: true)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: reportFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.reportIsRequired(userToReport: userToReport, postUid: postUid)))
        )
    }
}

//MARK: - Alert Methods

extension PostFlow {
    
    private func presentWelcomeIndicator(with nickname: String) -> FlowContributors {
        
        SPIndicator.present(
            title: "\(nickname)님",
            message: "환영합니다 🎉",
            preset: .custom(
                UIImage(systemName: "face.smiling")?.withTintColor(UIColor(named: K.Color.appColor)!, renderingMode: .alwaysOriginal)
                ?? UIImage(systemName: "checkmark.circle")!
            )
        )
        return .none
    }
    
    private func presentUnauthorizedAlert() -> FlowContributors {
        
        self.rootViewController.showSimpleBottomAlertWithAction(
            message: "학생 인증을 마치셔야 사용이 가능해요.👀",
            buttonTitle: "인증하러 가기"
        ) {
            let reactor = VerifyOptionViewReactor()
            let vc = VerifyOptionViewController(reactor: reactor)
            vc.hidesBottomBarWhenPushed = true
            self.rootViewController.pushViewController(vc, animated: true)
        }
        return .none
    }
    
    private func presentUnexpectedError() -> FlowContributors {
        self.rootViewController.presentCustomAlert(
            title: "예기치 못한 오류가 발생했습니다.🤔",
            message: "불편을 드려 죄송합니다. 다시 로그인 해주세요."
        ) {
            self.popToLoginScreen()
        }
        return .none
    }
    
    @discardableResult
    private func popToLoginScreen() -> FlowContributors {
        
        self.services.userDefaultsGenericService.resetAllUserInfo()
        
        let loginViewReactor = LoginViewReactor(userService: services.userService)
        let loginVC = LoginViewController(reactor: loginViewReactor)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginVC,
            withNextStepper: loginViewReactor
        ))
    }
}
