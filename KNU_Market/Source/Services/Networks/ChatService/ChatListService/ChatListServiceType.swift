//
//  ChatListServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/03.
//

import Foundation
import RxSwift

//MARK: - 채팅 목록 불러오기 화면에서 쓰이는 메서드를 모아놓은 Protocol

protocol ChatListServiceType: AnyObject {
    func fetchJoinedChatList() -> Single<NetworkResultWithArray<Room>>
}
