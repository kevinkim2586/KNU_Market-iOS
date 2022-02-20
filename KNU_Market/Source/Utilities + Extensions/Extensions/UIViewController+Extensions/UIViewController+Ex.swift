import Foundation
import UIKit
import SnackBar_swift
import BSImagePicker
import SafariServices
import Photos
import PMAlertController
import RxSwift
import RxCocoa
import SnapKit


//MARK: - PHAsset Conversion

extension UIViewController {
    
    func convertAssetToUIImages(selectedAssets: [PHAsset]) -> [UIImage] {
        
        var userSelectedImages: [UIImage] = []
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                option.resizeMode = .exact
                
                var thumbnail = UIImage()
                
                imageManager.requestImage(for: selectedAssets[i],
                                          targetSize: CGSize(width: 1000, height: 1000),
                                          contentMode: .aspectFit,
                                          options: option) { (result, info) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data!)
                
                userSelectedImages.append(newImage! as UIImage)
            }
        }
        return userSelectedImages
    }
}

