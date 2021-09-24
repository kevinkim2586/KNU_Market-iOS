import Foundation
import UIKit
import SnackBar_swift
import BSImagePicker
import SafariServices
import Photos
import PMAlertController

//MARK: - Alert Methods

extension UIViewController {
    
    // Custom Alert
    func presentKMAlertOnMainThread(title: String, message: String, buttonTitle: String, attributedMessageString: NSAttributedString? = nil) {
        DispatchQueue.main.async {
            let alertVC = AlertViewController(
                title: title,
                message: message,
                buttonTitle: buttonTitle,
                attributedMessageString: attributedMessageString
            )
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // Apple 기본 알림
    func presentSimpleAlert(title: String, message: String) {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "확인",
            style: .default
        )
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Completion Handler가 포함되어 있는 Alert Message
    func presentAlertWithCancelAction(title: String, message: String, completion: @escaping ((Bool) -> Void)) {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "확인",
            style: .default
        ) { pressedOk in
            completion(true)
        }
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        ) { pressedCancel in
            completion(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
    
        self.present(alertController, animated: true, completion: nil)
    }

    // SnackBar 라이브러리의 message 띄우기
    func showSimpleBottomAlert(with message: String) {
        SnackBar.make(
            in: self.view,
            message: message,
            duration: .lengthLong
        ).show()
    }
    
    // SnackBar 라이브러리의 액션이 추가된 message 띄우기
    func showSimpleBottomAlertWithAction(message: String,
                                         buttonTitle: String,
                                         action: (() -> Void)? = nil) {
        SnackBar.make(
            in: self.view,
            message: message,
            duration: .lengthLong
        ).setAction(
            with: buttonTitle,
            action: {
                action?()
            }).show()
    }
}

//MARK: - VC Router

extension UIViewController {
    
    // Initial VC로 돌아가는 메서드 (로그아웃, 회원 탈퇴, refreshToken 만료 등의 상황에 쓰임)
    func popToInitialViewController() {
        User.shared.resetAllUserInfo()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.initialVC
        )
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(initialVC)
    }
    
    // 로그인 or 회원가입 성공 시 홈화면 전환 시 사용되는 함수
    func goToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    // 유저 신고하기 VC
    func presentReportUserVC(userToReport: String, postUID: String? = nil) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: nil)
        
        guard let reportVC = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.reportUserVC
        ) as? ReportUserViewController else { return }
        
        reportVC.userToReport = userToReport
        reportVC.postUID = postUID ?? ""
        reportVC.modalPresentationStyle = .overFullScreen
      
        self.present(reportVC, animated: true)
    }
    
    // 인증하기 알림
    @objc func presentUserVerificationNeededAlert() {
        presentKMAlertOnMainThread(
            title: "인증이 필요합니다!",
            message: "앱 설정에서 학생증 또는 웹메일 인증을 마친 뒤 사용이 가능합니다.👀",
            buttonTitle: "확인"
        )
    }
    
    func popVCs(count: Int) {
        let viewControllers : [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        navigationController?.popToViewController(viewControllers[viewControllers.count - (count + 1) ], animated: false)
    }
    
    func presentSafariView(with url: URL) {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
    
    @objc func refreshTokenHasExpired() {
        presentKMAlertOnMainThread(
            title: "로그인 세션 만료 🤔",
            message: "세션이 만료되었습니다. 다시 로그인 해주세요.",
            buttonTitle: "확인"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popToInitialViewController()
        }
    }
    
    @objc func presentUnexpectedError() {
        presentKMAlertOnMainThread(
            title: "예기치 못한 오류가 발생했습니다.🤔",
            message: "불편을 드려 죄송합니다. 다시 로그인 해주세요.",
            buttonTitle: "확인"
        )
    }
    
    func presentInitialVerificationAlert() {
        let alertVC = PMAlertController(
            title: "경북대생 인증하기",
            description: "인증 방법(택1)\n1.모바일 학생증\n2.경북대 웹메일\n인증을 하지 않을 시,\n서비스 이용에 제한이 있습니다.\n추후 앱 설정에서 인증 가능",
            textsToChangeColor: ["1.모바일 학생증","서비스 이용에 제한"],
            image: nil,
            style: .alert
        )
        
        alertVC.addAction(PMAlertAction(title: "취소", style: .cancel))
        alertVC.addAction(PMAlertAction(title: "인증하기", style: .default, action: { () in
            self.presentVerifyOptionVC()
        }))
    
        present(alertVC, animated: true)
        User.shared.isAbsoluteFirstAppLaunch = false
    }
    
    func presentVerifyOptionVC() {
        let storyboard = UIStoryboard(name: "MyPage", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            identifier: Constants.StoryboardID.verifyOptionVC
        ) as? VerifyOptionViewController else { return }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UI Related

extension UIViewController {
    
    
    // UITableView 가 Fetching Data 중일 때 나타나는 Activity Indicator
    func createSpinnerFooterView() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.frame.size.width,
                                              height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func createSpinnerHeaderView() -> UIView {
        
        let headerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: view.frame.size.width,
                                              height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = headerView.center
        headerView.addSubview(spinner)
        spinner.startAnimating()
        return headerView
    }
    
    func addDismissButtonToRightNavBar() {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 150
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: statusBarHeight,
                                                          width: view.bounds.size.width, height: 50))
        navigationBar.tintColor = .darkGray
        navigationBar.setBackgroundImage(UIImage(),
                                         for: .default)
        navigationBar.backgroundColor = .white
        navigationBar.shadowImage = UIImage()
        view.addSubview(navigationBar)
        
        let navItem = UINavigationItem(title: "")
        let navBarButton = UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(dismissVC)
        )
        navItem.rightBarButtonItem = navBarButton
        navigationBar.items = [navItem]
    }
    
    func setBackBarButtonItemTitle(to title: String = "") {
        let backBarButtonItem = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func setNavigationBarAppearance(to color: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    func setClearNavigationBarBackground() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}

//MARK: - Observers

extension UIViewController {
    
    func createObserversForRefreshTokenExpiration() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTokenHasExpired),
            name: .refreshTokenExpired,
            object: nil
        )
    }
    
    func createObserversForPresentingVerificationAlert() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentUserVerificationNeededAlert),
            name: .presentVerifyEmailVC,
            object: nil
        )
    }
    
    func createObserversForGettingBadgeValue() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(getChatTabBadgeValue),
            name: .getBadgeValue,
            object: nil
        )
    }
    
    func createObserversForUnexpectedErrors() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentUnexpectedError),
            name: .unexpectedError,
            object: nil
        )
    }
    
}

//MARK: - PHAsset Conversion

extension UIViewController {
    
    func convertAssetToUIImages(selectedAssets: [PHAsset]) -> [UIImage] {
        
        var userSelectedImages: [UIImage] = []
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                option.resizeMode = .exact
                
                var thumbnail = UIImage()
                
                imageManager.requestImage(for: selectedAssets[i],
                                          targetSize: CGSize(width: 1000, height: 1000),
                                          contentMode: .aspectFit,
                                          options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data!)
                
                userSelectedImages.append(newImage! as UIImage)
            }
        }
        return userSelectedImages
    }
}

//MARK: - Notification Related

extension UIViewController {

    @objc func getChatTabBadgeValue() {
        
        if let tabItems = tabBarController?.tabBar.items {
            
            let chatTabBarItem = tabItems[1]
            
            if User.shared.chatNotificationList.count == 0 {
                chatTabBarItem.badgeValue = nil
            } else {
                chatTabBarItem.badgeValue = "\(User.shared.chatNotificationList.count)"
            }
        }
    }
    
    // 최초 알림 허용 메시지
    func askForNotificationPermission() {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, _ in
            
            guard granted else {
                
                User.shared.hasAllowedForNotification = false
                
                DispatchQueue.main.async {
                    self.presentAlertWithCancelAction(title: "알림 받기를 설정해 주세요.👀",
                                                 message: "알림 받기를 설정하지 않으면 공구 채팅 알림을 받을 수 없어요. '확인'을 눌러 설정으로 이동 후 알림 켜기를 눌러주세요.😁") { selectedOk in
                        if selectedOk {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                      options: [:],
                                                      completionHandler: nil)
                        }
                    }
                }
                return
            }
            
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    User.shared.hasAllowedForNotification = true
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

//MARK: - Utilities

extension UIViewController {
    
    func detectIfVerifiedUser() -> Bool {
        return User.shared.isVerified ? true : false
    }
}
