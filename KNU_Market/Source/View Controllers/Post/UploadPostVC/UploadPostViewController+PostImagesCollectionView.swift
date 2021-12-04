//
//  UploadPostViewController+PostImagesCollectionView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

//MARK: - AddPostImageDelegate

extension UploadPostViewController: AddPostImageDelegate {
    
    func didPickImagesToUpload(images: [UIImage]) {
        viewModel.userSelectedImages = images
        postImagesCollectionView.reloadData()
    }

    
}

//MARK: - UserPickedPostImageCellDelegate

extension UploadPostViewController: UserPickedPostImageCellDelegate {
    
    func didPressDeleteImageButton(at index: Int) {
        viewModel.userSelectedImages.remove(at: index - 1)
        postImagesCollectionView.reloadData()
    }
}
