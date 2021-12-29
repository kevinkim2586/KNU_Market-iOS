//
//  UIViewController+VC_Routers.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit
import SafariServices
import PMAlertController


//MARK: - VC Router

extension UIViewController {
    
    // Login VC로 돌아가는 메서드 (로그아웃, 회원 탈퇴, refreshToken 만료 등의 상황에 쓰임)
    func popToLoginViewController() {
        User.shared.resetAllUserInfo()
        let loginVC = LoginViewController(
            reactor: LoginViewReactor(
                userService: UserService(network: Network<UserAPI>())
            )
        )
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginVC)
    }
    
    // 로그인 or 회원가입 성공 시 홈화면 전환 시 사용되는 함수
    func goToHomeScreen() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(UIHelper.createMainTabBarController())
    }
    
    // 유저 신고하기 VC
    func presentReportUserVC(userToReport: String, postUID: String? = nil) {
        let reportVC = ReportUserViewController(
            reactor: ReportUserViewReactor(
                reportService: ReportService(
                    network: Network<ReportAPI>(plugins: [AuthPlugin()])),
                userToReport: userToReport,
                postUid: postUID ?? ""
            )
        )
        reportVC.modalPresentationStyle = .overFullScreen
        self.present(reportVC, animated: true)
    }
    
    // 인증하기 알림
    @objc func presentUserVerificationNeededAlert() {
        presentCustomAlert(title: "인증이 필요합니다!", message: "앱 설정에서 학생증 또는 웹메일 인증을 마친 뒤 사용이 가능합니다.👀")
    }
    
    func popVCsFromNavController(count: Int) {
        let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        navigationController?.popToViewController(viewControllers[viewControllers.count - (count + 1) ], animated: true)
    }
    
    func presentSafariView(with url: URL) {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    @objc func refreshTokenHasExpired() {
        presentCustomAlert(title: "로그인 세션 만료 🤔", message: "세션이 만료되었습니다. 다시 로그인 해주세요.") { self.popToLoginViewController() }
    }
    
    @objc func presentUnexpectedError() {
        presentCustomAlert(title: "예기치 못한 오류가 발생했습니다.🤔", message: "불편을 드려 죄송합니다. 다시 로그인 해주세요.") { self.popToLoginViewController() }

    }
    
//    func presentInitialVerificationAlert() {
//        let alertVC = PMAlertController(
//            title: "경북대생 인증하기",
//            description: "경북대 웹메일 인증 외에도\n학생증 인증이 추가되었어요!\n인증 가능한 방법\n- 경북대 웹메일 인증\n- 모바일 학생증 인증",
////            textsToChangeColor: ["학생증 인증이 추가","인증 가능한 방법"],
//            image: nil,
//            style: .alert
//        )
//
//        alertVC.addAction(PMAlertAction(title: "지금 인증하기", style: .default, action: { () in
//            self.presentVerifyOptionVC()
//        }))
//        alertVC.addAction(PMAlertAction(title: "나중에 할래요", style: .cancel, action: {
//            self.presentServiceLimitationNoticeAlert()
//        }))
//
//
//        present(alertVC, animated: true)
//        User.shared.isNotFirstAppLaunch = true
//    }
//
//    func presentServiceLimitationNoticeAlert() {
//
//        let message = "미인증 유저는 서비스 이용에 아래와 같은 제한이 있습니다."
//
//        let alertVC = PMAlertController(
//            title: nil,
//            description: message + "\n1. 공구모집 글 개설 불가\n2. 공구 채팅방에 참가 불가",
////            textsToChangeColor: [message],
//            image: nil,
//            style: .alert
//        )
//
//        alertVC.addAction(PMAlertAction(title: "확인했어요.", style: .cancel))
//        present(alertVC, animated: true)
//    }
    
    // 인증 수단 고르기 화면 띄우기
    func presentVerifyOptionVC() {
        let vc = VerifyOptionViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 회원가입 VC 띄우기
    func presentRegisterVC() {
        let vc = IDInputViewController(
            reactor: IDInputViewReactor(
                userService: UserService(network: Network<UserAPI>())
            )
        )
        let navController = UINavigationController(rootViewController: vc)
        navController.navigationBar.tintColor = UIColor.black
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true)
    }
}
