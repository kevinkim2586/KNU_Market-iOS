//
//  ChatViewController+TargetMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatViewController {
    
    @objc func pressedTitle() {
        self.steps.accept(AppStep.postIsPicked(postUid: roomUID, isFromChatVC: true))
    }

    @objc func pressedMoreBarButtonItem() {
        viewModel.getRoomInfo()
        
        self.steps.accept(AppStep.chatMemberListIsRequired(roomInfo: viewModel.roomInfo, postUploaderUid: viewModel.postUploaderUID))
    }
    
    @objc func pressedRefreshButton() {
        viewModel.resetAndReconnect()
    }

    func showChatPrecautionMessage() {

        presentKMAlertOnMainThread(
            title: "채팅 에티켓 공지!",
            message: "폭력적이거나 선정적인 말은 삼가 부탁드립니다. 타 이용자로부터 신고가 접수되면 서비스 이용이 제한될 수 있습니다.",
            buttonTitle: "확인"
        )
    }
}
