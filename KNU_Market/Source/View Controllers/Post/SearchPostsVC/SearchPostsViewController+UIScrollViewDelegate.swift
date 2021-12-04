//
//  SearchPostsViewController+UIScrollViewDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension SearchPostsViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (searchTableView.contentSize.height - 20 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                viewModel.fetchSearchResults()
            }
        }
    }
}
