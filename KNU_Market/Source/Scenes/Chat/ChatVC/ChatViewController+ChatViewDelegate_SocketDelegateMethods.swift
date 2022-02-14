//
//  ChatViewController+ChatViewDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import Foundation

extension ChatViewController: ChatViewDelegate {

    func didConnect() {
        activityIndicator.stopAnimating()

        messagesCollectionView.scrollToLastItem()

        if viewModel.isFirstEntranceToChat {
            viewModel.sendText("\(User.shared.nickname)\(K.ChatSuffix.enterSuffix)")
            viewModel.isFirstEntranceToChat = false
            showChatPrecautionMessage()
        }
        
        viewModel.fetchFromLastChat
        ? viewModel.getChatFromLastIndex()
        : viewModel.getPreviousChats()
    }

    func didDisconnect() {
        dismissProgressBar()
        self.steps.accept(AppStep.popViewController)
    }

    func didReceiveChat() {
        dismissProgressBar()
        messagesCollectionView.backgroundView = nil
        messagesCollectionView.reloadDataAndKeepOffset()
    }

    func reconnectSuggested() {
        dismissProgressBar()
        viewModel.resetMessages()
        viewModel.connect()
    }

    func failedConnection(with error: NetworkError) {
        dismissProgressBar()
        presentKMAlertOnMainThread(
            title: "일시적인 연결 문제 발생",
            message: error.errorDescription,
            buttonTitle: "확인"
        )
    }

    func didSendText() {
        DispatchQueue.main.async {
            self.messageInputBar.inputTextView.text = ""
            self.messagesCollectionView.scrollToLastItem()
        }
    }

    func didReceiveBanNotification() {
        messageInputBar.isUserInteractionEnabled = false
        messageInputBar.isHidden = true
        viewModel.disconnect()
        viewModel.resetMessages()

        messagesCollectionView.isScrollEnabled = false

        presentKMAlertOnMainThread(
            title: "강퇴 당하셨습니다.",
            message: "방장에 의해 강퇴되었습니다. 더 이상 채팅에 참여가 불가능합니다.🤔",
            buttonTitle: "확인"
        )
        self.steps.accept(AppStep.popViewControllerWithDelay(seconds: 1))

    }
}
