//
//  UIViewController+Alert_Extensions.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import UIKit
import SnackBar_swift
import RxSwift
import RxCocoa

//MARK: - Alert Methods - Pure Swift

extension UIViewController {
    
    func presentCustomAlert(
        title: String,
        message: String,
        cancelButtonTitle: String = "취소",
        actionButtonTitle: String = "확인",
        action: @escaping () -> Void = { }
    ) {
        let vc = CustomAlertViewController(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            actionButtonTitle: actionButtonTitle,
            action: action
        )
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    // Custom Alert
    func presentKMAlertOnMainThread(
        title: String,
        message: String,
        buttonTitle: String = "확인",
        attributedMessageString: NSAttributedString? = nil
    ) {
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
    func presentAlertWithCancelAction(
        title: String,
        message: String,
        completion: @escaping ((Bool) -> Void)
    ) {
        
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
    func showSimpleBottomAlertWithAction(
        message: String,
        buttonTitle: String,
        action: (() -> Void)? = nil
    ) {
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

//MARK: - UIAlertController Rx

enum ActionType {
    case ok
    case cancel
}

extension UIViewController {
    
    func presentAlertWithConfirmation(title: String, message: String? = nil) -> Observable<ActionType> {
        return Observable.create { [weak self] observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alertController.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true)
            }
        }
    }
    
    func presentAlert(title: String, message: String? = nil) -> Observable<ActionType> {
        return Observable.create { [weak self] observer in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            alertController.addAction(okAction)
            self?.present(alertController, animated: true, completion: nil)
            return Disposables.create {
                alertController.dismiss(animated: true)
            }
        }
    }
    
    // 프로필 이미지 변경 또는 제거를 도와주는 ActionSheet 을 생성
    func presentChangeProfileImageOptionsActionSheet() -> Observable<ChangeProfileImageType> {
        return Observable.create { [weak self] observer in
            let actionSheet = UIAlertController(
                title: "프로필 사진 변경",
                message: nil,
                preferredStyle: .actionSheet
            )
            actionSheet.view.tintColor = .black
            
            let library = UIAlertAction(
                title: "앨범에서 선택",
                style: .default
            ) { _ in
                observer.onNext(.selectFromLibrary)
                observer.onCompleted()
            }
            
            let remove = UIAlertAction(
                title: "프로필 사진 제거",
                style: .default
            ) { _ in
                observer.onNext(.remove)
                observer.onCompleted()
            }
            
            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel
            ) { _ in
                observer.onNext(.cancel)
                observer.onCompleted()
            }
        
            actionSheet.addAction(library)
            actionSheet.addAction(remove)
            actionSheet.addAction(cancelAction)
            self?.present(actionSheet, animated: true, completion: nil)
    
            return Disposables.create {
                actionSheet.dismiss(animated: true, completion: nil)
            }
        }
    }
}

enum ChangeProfileImageType {
    case selectFromLibrary
    case remove
    case cancel
}

