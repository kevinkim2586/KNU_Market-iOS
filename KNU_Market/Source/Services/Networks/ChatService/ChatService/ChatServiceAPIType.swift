//
//  ChatServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift

//MARK: - 채팅 화면(ChatVC) 에서 쓰이는 API 메서드들

protocol ChatServiceAPIType: AnyObject {
    func changeJoinStatus(chatFunction: ChatFunction, pid: String) -> Single<NetworkResult>
    func getRoomInfo(pid: String) -> Single<NetworkResultWithValue<RoomInfo>>
    func fetchJoinedChatList() -> Single<NetworkResultWithArray<Room>>
    func getPreviousChats(pid: String, index: Int) -> Single<NetworkResultWithArray<ChatResponseModel>>
    func getNewlyReceivedChats(pid: String, index: Int, lastChatDate: String) -> Single<NetworkResultWithArray<ChatResponseModel>>
    func banUser(userUid: String, room: String) -> Single<NetworkResult>
}
