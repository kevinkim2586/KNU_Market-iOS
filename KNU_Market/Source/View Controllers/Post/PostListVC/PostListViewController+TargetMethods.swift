//
//  PostListViewController+TargetMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension PostListViewController {
    
    @objc func pressedLogoBarButton() {
        postListsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    @objc func pressedSearchBarButton() {
        
        let searchVC = SearchPostsViewController(
            viewModel: SearchPostViewModel(postManager: PostManager())
        )
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func pressedFilterBarButton() {
        let changePostFilterAction = UIAlertAction(
            title: viewModel.filterActionTitle,
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.changePostFilterOption()
        }
        
        let actionSheet = UIHelper.createActionSheet(with: [changePostFilterAction], title: "글 정렬 기준")
        present(actionSheet, animated: true)
    }

    @objc func pressedAddPostButton() {
        
        if !detectIfVerifiedUser() {
            showSimpleBottomAlertWithAction(
                message: "학생 인증을 마치셔야 사용이 가능해요.👀",
                buttonTitle: "인증하러 가기"
            ) {
                self.presentVerifyOptionVC()
            }
            return
        }
        
        let uploadVC = UploadPostViewController(
            viewModel: UploadPostViewModel(
                postManager: PostManager(),
                mediaManager: MediaManager()
            )
        )
        
        navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTableView),
            name: .updatePostList,
            object: nil
        )

        createObserversForGettingBadgeValue()
        createObserversForRefreshTokenExpiration()
        createObserversForUnexpectedErrors()
    }
    
}
