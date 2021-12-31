//
//  AssetConverter.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/31.
//

import UIKit
import Photos

struct AssetConverter {
    
    static func convertAssetToImage(_ assets: [PHAsset]) -> [UIImage] {
        var result: [UIImage] = []
        if assets.count != 0 {
            for i in 0 ..< assets.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                var thumbnail = UIImage()
                imageManager.requestImage(
                    for: assets[i],
                       targetSize: CGSize(width: 1000, height: 1000),
                       contentMode: .aspectFill,
                       options: option
                ) {
                    (result, _) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data!)
                result.append(newImage! as UIImage)
            }
        }
        return result
    }
}
