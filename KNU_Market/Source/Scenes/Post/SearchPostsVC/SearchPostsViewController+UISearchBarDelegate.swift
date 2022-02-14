//
//  SearchPostsViewController+UISearchBarDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit


extension SearchPostsViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchKey = searchBar.text else { return }
        guard !searchKey.hasEmojis else {
            searchBar.resignFirstResponder()
            searchTableView.showEmptyView(
                imageName: K.Images.emptySearchPlaceholder,
                text: "이모티콘 검색은 지원하지 않습니다!"
            )
            return
        }
        searchBar.resignFirstResponder()
        viewModel.resetValues()
        viewModel.searchKeyword = searchKey
        viewModel.fetchSearchResults()
        
    }
}
