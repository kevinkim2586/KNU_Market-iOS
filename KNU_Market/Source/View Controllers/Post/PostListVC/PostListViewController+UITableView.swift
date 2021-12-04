//
//  PostListViewController+UITableView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension PostListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.postList.count
            || viewModel.postList.count == 0 { return UITableViewCell() }
        
        let cellIdentifier = PostTableViewCell.cellId
                
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? PostTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: viewModel.postList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
          
        let postVC = PostViewController(
            viewModel: PostViewModel(
                pageId: viewModel.postList[indexPath.row].uuid,
                postManager: PostManager(),
                chatManager: ChatManager()
            ),
            isFromChatVC: false
        )
        
        navigationController?.pushViewController(postVC, animated: true)
    }

    @objc func refreshTableView() {
        
        //사라지는 애니메이션 처리
        UIView.animate(
            views: postListsTableView.visibleCells,
            animations: Animations.forTableViews,
            reversed: true,
            initialAlpha: 1.0,      // 보이다가
            finalAlpha: 0.0,        // 안 보이게
            completion: {
                self.viewModel.refreshTableView()
            }
        )
    }
}
