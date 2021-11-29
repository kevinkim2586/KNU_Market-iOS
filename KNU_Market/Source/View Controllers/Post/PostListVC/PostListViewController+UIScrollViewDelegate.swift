//
//  PostListViewController+UIScrollViewDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension PostListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (postListsTableView.contentSize.height - 50 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                postListsTableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchPostList()
            }
        }
    }
}
