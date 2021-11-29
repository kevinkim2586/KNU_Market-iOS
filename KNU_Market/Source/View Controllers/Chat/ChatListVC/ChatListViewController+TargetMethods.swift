//
//  ChatListViewController+TargetMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatListViewController {
    
    @objc func pressedChatBarButtonItem() {
        if viewModel.roomList.count == 0 { return }
        let topRow = IndexPath(row: 0, section: 0)
        chatListTableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
}

