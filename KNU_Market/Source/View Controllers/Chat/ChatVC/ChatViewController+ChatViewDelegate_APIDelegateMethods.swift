//
//  ChatViewController+ChatViewDelegate_APIDelegateMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatViewController {

    func didExitPost() {
        navigationController?.popViewController(animated: true)
    }

    func didDeletePost() {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .updatePostList, object: nil)
    }

    func didFetchPreviousChats() {

        dismissProgressBar()
        messagesCollectionView.backgroundView = nil

        if viewModel.isFirstViewLaunch {

            viewModel.isFirstViewLaunch = false
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem()

        } else {
            messagesCollectionView.reloadDataAndKeepOffset()
        }

        if viewModel.messages.count == 0 {
            messagesCollectionView.showEmptyChatView()
        }
    }
    
    func didFetchChatFromLastIndex() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
    
    func didFetchEmptyChat() {
        if viewModel.messages.count == 0 {
            messagesCollectionView.showEmptyChatView()
        }
    }
    
    func failedFetchingPreviousChats(with error: NetworkError) {
        print("❗️ failedFetchingPreviousChats")
        dismissProgressBar()
    }
    
    func failedUploadingImageToServer() {
        dismissProgressBar()
        presentKMAlertOnMainThread(
            title: "사진 업로드 실패",
            message: "사진 용량이 너무 크거나 일시적인 오류로 업로드에 실패하였습니다. 잠시 후 다시 시도해주세요.😥",
            buttonTitle: "확인"
        )
        
    }
}
