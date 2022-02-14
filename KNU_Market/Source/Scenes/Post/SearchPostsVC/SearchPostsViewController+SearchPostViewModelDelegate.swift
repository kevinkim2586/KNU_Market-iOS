//
//  SearchPostsViewController+SearchPostViewModelDelegate.swift
//  
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension SearchPostsViewController: SearchPostViewModelDelegate {
    
    func didFetchSearchList() {
        
        if viewModel.postList.count == 0 {
            searchTableView.showEmptyView(
                imageName: K.Images.emptySearchPlaceholder,
                text: K.placeHolderTitle.emptySearchTitleList.randomElement()!
            )
        }
        searchTableView.reloadData()
        searchTableView.tableFooterView = nil
        searchTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingSearchList(with error: NetworkError) {
        
        searchTableView.reloadData()
        searchTableView.tableFooterView = nil
        searchTableView.tableFooterView = UIView(frame: .zero)
        
        let errorText = error == .E401
        ? "두 글자 이상 입력해주세요."
        : "오류가 발생했습니다. 잠시 후 다시 시도해주세요."
        
        searchTableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: errorText
        )

    }
}
