//
//  PostListViewController+PostViewModelDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit
import SPIndicator
import Moya

extension PostListViewController: PostListViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        
        guard let defaultImage = UIImage(systemName: "checkmark.circle") else { return }
        
        SPIndicator.present(
            title: "\(User.shared.nickname)님",
            message: "환영합니다 🎉",
            preset: .custom(UIImage(systemName: "face.smiling")?.withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink, renderingMode: .alwaysOriginal) ?? defaultImage)
        )
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        showSimpleBottomAlertWithAction(
            message: "사용자 정보 불러오기에 실패하였습니다. 로그아웃 후 다시 이용해 주세요.😥",
            buttonTitle: "로그아웃"
        ) {
            self.popToLoginViewController()
        }
    }
    
    func didFetchPostList() {
        postListsTableView.reloadData()
        postListsTableView.refreshControl?.endRefreshing()
        postListsTableView.tableFooterView = nil
    }
    
    func failedFetchingPostList(errorMessage: String, error: NetworkError) {
        postListsTableView.refreshControl?.endRefreshing()
        postListsTableView.tableFooterView = nil
        if error != .E601 {
            postListsTableView.showErrorPlaceholder()
        }
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didFetchLatestPopup(model: PopupModel) {
        let popupVC = PopupViewController(
            reactor: PopupReactor(
                popupUid: model.popupUid,
                mediaUid: model.mediaUid,
                landingUrlString: model.landingUrl,
                popupService: PopupService(network: Network<PopupAPI>(plugins: [NetworkLoggerPlugin()])))
        )
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        self.present(popupVC, animated: true)
    }
    
    func failedFetchingLatestPopup(with error: NetworkError) {
        print("❗️failedFetchingLatestPopup ")
    }
}
