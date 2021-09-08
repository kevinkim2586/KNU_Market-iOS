import Foundation
import UIKit
import SnackBar_swift
import BSImagePicker
import SafariServices
import Photos

//MARK: - Alert Methods

extension UIViewController {
    
    func presentKMAlertOnMainThread(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alertVC = AlertViewController(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    // 가장 기본적인 Alert Message
    func presentSimpleAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default)
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Completion Handler가 포함되어 있는 Alert Message
    func presentAlertWithCancelAction(title: String, message: String, completion: @escaping ((Bool) -> Void)) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { pressedOk in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel) { pressedCancel in
            completion(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
    
        self.present(alertController, animated: true, completion: nil)
    }

    // SnackBar 라이브러리의 message 띄우기
    func showSimpleBottomAlert(with message: String) {
        SnackBar.make(in: self.view,
                      message: message,
                      duration: .lengthLong).show()
    }
    
    // SnackBar 라이브러리의 액션이 추가된 message 띄우기
    func showSimpleBottomAlertWithAction(message: String,
                                         buttonTitle: String,
                                         action: (() -> Void)? = nil) {
        SnackBar.make(in: self.view,
                      message: message,
                      duration: .lengthLong).setAction(
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
        let initialVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.initialVC)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(initialVC)
    }
    
    // 로그인 or 회원가입 성공 시 홈화면 전환 시 사용되는 함수
    func goToHomeScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    // 유저 신고하기 VC
    func presentReportUserVC(userToReport: String, postUID: String) {
        
        let storyboard = UIStoryboard(name: "Report", bundle: nil)
        
        guard let reportVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.reportUserVC) as? ReportUserViewController else { return }
        
        reportVC.userToReport = userToReport
        reportVC.postUID = postUID
        reportVC.modalPresentationStyle = .overFullScreen
      
        self.present(reportVC, animated: true)
    }
    
    // 이메일 인증하기 VC
    @objc func presentVerifyEmailVC() {
        
        let storyboard = UIStoryboard(name: "VerifyEmail", bundle: nil)
        
        guard let verifyEmailVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.verifyEmailVC) as? VerifyEmailViewController else { return }
        
        verifyEmailVC.modalPresentationStyle = .overFullScreen
        
        self.present(verifyEmailVC, animated: true)
    }
    
    func presentSafariView(with url: URL) {
        let config = SFSafariViewController.Configuration()
        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
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
        navigationBar.tintColor = .lightGray
        navigationBar.setBackgroundImage(UIImage(),
                                         for: .default)
        navigationBar.shadowImage = UIImage()
        self.view.addSubview(navigationBar)
        
        let navItem = UINavigationItem(title: "")
        let navBarButton = UIBarButtonItem(barButtonSystemItem: .stop,
                                           target: self,
                                           action: #selector(dismissVC))
        navItem.rightBarButtonItem = navBarButton
        navigationBar.items = [navItem]
    }
    
    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Observers

extension UIViewController {
    
    func createObserversForPresentingEmailVerification() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentVerifyEmailVC),
                                               name: .presentVerifyEmailVC,
                                               object: nil)
    }
    
    func createObserversForGettingBadgeValue() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getChatTabBadgeValue),
                                               name: .getBadgeValue,
                                               object: nil)
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
                print("Notification settings: \(settings)")
                DispatchQueue.main.async {
                    User.shared.hasAllowedForNotification = true
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

