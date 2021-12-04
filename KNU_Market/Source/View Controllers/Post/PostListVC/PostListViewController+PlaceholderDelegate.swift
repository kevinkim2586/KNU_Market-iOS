//
//  PostListViewController+PlaceholderDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit
import HGPlaceholders

extension PostListViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        postListsTableView.refreshControl?.beginRefreshing()
        self.viewModel.resetValues()
        self.viewModel.fetchPostList()
    }
}

