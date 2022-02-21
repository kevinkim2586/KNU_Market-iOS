//
//  AssetConverter.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/31.
//

import UIKit
import SDWebImage
import ImageSlideshow
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
    
    static func convertImagePathsToInputSources(imagePaths: [File]) -> [InputSource] {
        
        let imageURLs = imagePaths.compactMap {
            URL(string: $0.location ?? "")
        }
        
        var imageSources: [InputSource] = []
        
        imageURLs.forEach { imageURL in
            imageSources.append(SDWebImageSource(
                url: imageURL,
                placeholder: UIImage(named: K.Images.defaultItemImage))
            )
        }
        return imageSources
    }
    
    static func convertImageUIDsToInputSources(imageUIDs: [String]) -> [InputSource] {
        
        let imageURLs = imageUIDs.compactMap {
            URL(string: K.MEDIA_REQUEST_URL + $0)
        }
        
        var imageSources: [InputSource] = []
        
        imageURLs.forEach { imageURL in
            imageSources.append(SDWebImageSource(
                url: imageURL,
                placeholder: UIImage(named: K.Images.defaultItemImage))
            )
        }
        return imageSources
    }
    
    static func convertUIImagesToDataType(images: [UIImage]) -> [Data] {
        guard !images.isEmpty else { return [] }
        let imageData: [Data] = images.map { image in
            return image.jpegData(compressionQuality: 1.0) ?? Data()
        }
        return imageData
    }
}
