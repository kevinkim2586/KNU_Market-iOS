//
//  SearchPostsViewController+PlaceholderDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit
import HGPlaceholders

extension SearchPostsViewController: PlaceholderDelegate {
    
    func view(_ view: Any, actionButtonTappedFor placeholder: Placeholder) {
        self.viewModel.resetValues()
        self.viewModel.fetchSearchResults()
    }
}
