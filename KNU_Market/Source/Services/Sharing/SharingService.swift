//
//  SharingService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/27.
//

import UIKit
import FirebaseDynamicLinks


final class SharingService: SharingServiceType {
    
    private let scheme: String  = "https"
    private let host: String    = "knumarket.page.link"
    private let domainURIPrefix = "https://knumarket.page.link"
    
    
    private enum OSParameters: String {
        case androidPackageName = "com.kyh.knumarket"
        case iOSAppStoreId      = "1580677279"
    }
    
    // 공구글 공유
    func sharePost(postUid: String, titleMessage: String, imageFilePaths: [File]?) {

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = ComponentPath.post.rawValue
        
        let postUIDQueryItem = URLQueryItem(
            name: QueryItem.post.rawValue,
            value: postUid
        )
        components.queryItems = [postUIDQueryItem]
        
        guard let linkParameter = components.url else { return }
        
        guard let shareLink = DynamicLinkComponents.init(
            link: linkParameter,
            domainURIPrefix: domainURIPrefix
        ) else { return }
        
        shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: OSParameters.androidPackageName.rawValue)
        
        if let myBundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        shareLink.iOSParameters?.appStoreID = OSParameters.iOSAppStoreId.rawValue
        
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = titleMessage + " 같이 사요!"
        shareLink.socialMetaTagParameters?.descriptionText = "자세한 내용은 크누마켓에서 확인하세요."
        
        if let imageFilePaths = imageFilePaths, let location = imageFilePaths[0].location {
            shareLink.socialMetaTagParameters?.imageURL = URL(string: location)
        }
        
        shareLink.shorten { url, _, error in
            
            if let error = error {
                print("❗️ error in shortening URL: \(error)")
                return
            }
            
            guard let url = url else { return }
            print("✅ SHORTENED URL: \(url)")
            
            let promoText = titleMessage + " 같이 사요!"
            
            let activityVC = UIActivityViewController(
                activityItems: [promoText, url],
                applicationActivities: nil
            )
            
            guard let rootVC = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController else {
                return
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}

