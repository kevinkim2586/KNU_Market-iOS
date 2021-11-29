//
//  PostViewController+KMPostBottomViewDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension PostViewController: KMPostBottomViewDelegate {
    
    func didPressEnterChatButton() {
        
        postBottomView.enterChatButton.loadingIndicator(true)
        
        if isFromChatVC { navigationController?.popViewController(animated: true) }
        viewModel.joinPost()
    }
}
