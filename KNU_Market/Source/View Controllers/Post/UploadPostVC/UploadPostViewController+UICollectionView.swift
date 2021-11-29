//
//  UploadPostViewController+UICollectionView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension UploadPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.userSelectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? AddPostImageCollectionViewCell else { fatalError() }
            cell.delegate = self
            return cell
        }
        else {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserPickedPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? UserPickedPostImageCollectionViewCell else { fatalError() }
            
            cell.delegate = self
            cell.indexPath = indexPath.item
            
            if viewModel.userSelectedImages.count > 0 {
                cell.userPickedPostImageView.image = viewModel.userSelectedImages[indexPath.item - 1]
            }
            return cell
        }
        
    }
    
}
