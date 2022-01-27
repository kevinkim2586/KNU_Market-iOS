//
//  SharingServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/27.
//

import Foundation

protocol SharingServiceType {
    func sharePost(postUid: String, titleMessage: String, imageUids: [String]?)
}
