//
//  PostViewController+PostViewModelDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension PostViewController: PostViewModelDelegate {
    
    func didFetchPostDetails() {
        DispatchQueue.main.async {
            self.postTableView.refreshControl?.endRefreshing()
            self.updatePostInformation()
        }
    }
    
    func failedFetchingPostDetails(with error: NetworkError) {
        self.postTableView.refreshControl?.endRefreshing()
        
        postTableView.isHidden = true
        postBottomView.isHidden = true
        
        showSimpleBottomAlertWithAction(
            message: "존재하지 않는 글입니다 🧐",
            buttonTitle: "홈으로",
            action: {
                self.navigationController?.popViewController(animated: true)
            }
        )
    }
    
    func didDeletePost() {
        dismissProgressBar()
        showSimpleBottomAlert(with: "게시글 삭제 완료 🎉")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .updatePostList, object: nil)
        }
    }
    
    func failedDeletingPost(with error: NetworkError) {
        dismissProgressBar()
        showSimpleBottomAlertWithAction(
            message: error.errorDescription,
            buttonTitle: "재시도"
        ) {
            self.viewModel.deletePost()
        }
    }
    
    func didMarkPostDone() {
        showSimpleBottomAlert(with: "모집 완료를 축하합니다.🎉")
        refreshPage()
    }
    
    func failedMarkingPostDone(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didCancelMarkPostDone() {
        refreshPage()
    }
    
    func failedCancelMarkPostDone(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didEnterChat(isFirstEntrance: Bool) {
        
        let vc = ChatViewController()
        
        vc.roomUID = viewModel.pageID
        vc.chatRoomTitle = viewModel.model?.title ?? ""
        
        vc.isFirstEntrance = isFirstEntrance ? true : false
        
        navigationController?.pushViewController(vc, animated: true)
        postBottomView.enterChatButton.loadingIndicator(false)
    }
    
    func failedJoiningChat(with error: NetworkError) {
        presentCustomAlert(title: "채팅방 참여 불가", message: error.errorDescription)
        postBottomView.enterChatButton.loadingIndicator(false)
    }
    
    func didBlockUser() {
        showSimpleBottomAlert(with: "앞으로 \(viewModel.model?.nickname ?? "해당 유저")의 게시글이 목록에서 보이지 않습니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func didDetectURL(with string: NSMutableAttributedString) {
        postTableView.reloadData()
    }
    
    func failedLoadingData(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
    }
}
