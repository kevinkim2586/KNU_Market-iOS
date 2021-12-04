//
//  UploadPostViewController+UploadPostDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension UploadPostViewController: UploadPostDelegate {
    
    func didCompleteUpload() {
        
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .updatePostList, object: nil)
    }
    
    func failedUploading(with error: NetworkError) {
        
        dismissProgressBar()
        showSimpleBottomAlert(with: "업로드 실패: \(error.errorDescription)")
        navigationController?.popViewController(animated: true)
    }
    
    func didUpdatePost() {
        
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
    }
    
    func failedUpdatingPost(with error: NetworkError) {

        dismissProgressBar()
        showSimpleBottomAlert(with: NetworkError.E000.errorDescription)
        navigationController?.popViewController(animated: true)
    }
}
