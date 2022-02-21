//
//  ChatListViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/04.
//

import Foundation
import RxSwift
import RxFlow
import RxRelay
import ReactorKit

final class ChatListViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    let chatListService: ChatListServiceType
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    enum Action {
        case getChatList
        case viewDidDisappear
        case removeChatNotification(IndexPath)
        case chatSelected(IndexPath)
    }
    
    enum Mutation {
        case setChatList([Room])
        case setApplicationIconBadgeNumber(Int)
        case removeAllDeliveredNotifications
        case setNeedsToShowEmptyView(Bool)
        case setErrorMessage(String)
        case setFetchingData(Bool)
    }
    
    struct State {
        
        var roomList: [Room] = [] {
            willSet {
                self.roomList.removeAll()       // 한 번에 다 불러오기 때문에 기존값 초기화 먼저 수행
            }
        }
        
        var isFetchingData: Bool = false
        var needsToShowEmptyView: Bool = false
        var errorMessage: String?
    }
    
    init(chatListService: ChatListServiceType, userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.chatListService = chatListService
        self.userDefaultsGenericService = userDefaultsGenericService
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
    
        case .getChatList:
            NotificationCenterService.configureChatTabBadgeCount.post(object: nil)

            guard currentState.isFetchingData == false else { return Observable.empty() }
            
            let chatNotificationList: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.notificationList) ?? []
            
            return Observable.concat([
                
                Observable.just(Mutation.setFetchingData(true)),
                Observable.just(Mutation.setApplicationIconBadgeNumber(chatNotificationList.count)),
                Observable.just(Mutation.removeAllDeliveredNotifications),
                
                self.chatListService.fetchJoinedChatList()
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let rooms):
                            // 참여하고 있는 공구 리스트 값 User Defaults에 저장
                            self.userDefaultsGenericService.set(
                                key: UserDefaults.Keys.joinedChatRoomPIDs,
                                value: rooms.map { $0.channelId }
                            )
                            return rooms.count == 0
                            ? Mutation.setNeedsToShowEmptyView(true)
                            : Mutation.setChatList(rooms)
                            
                        case .error(_):
                            return Mutation.setErrorMessage("채팅 목록을 불러오지 못했습니다.😥")
                        }
                    },
                
                Observable.just(Mutation.setFetchingData(false))
            ])
            
        case .viewDidDisappear:
            return Observable.just(Mutation.setFetchingData(false))
            
        case .removeChatNotification(let indexPath):
            
            var currentChatNotificationList: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.notificationList) ?? []
            
            if let index = currentChatNotificationList.firstIndex(of: currentState.roomList[indexPath.row].channelId) {
                currentChatNotificationList.remove(at: index)
                userDefaultsGenericService.set(
                    key: UserDefaults.Keys.notificationList,
                    value: currentChatNotificationList
                )
                NotificationCenter.default.post(name: .configureChatTabBadgeCount, object: nil)
            }
            return Observable.empty()
            
        case .chatSelected(let indexPath):
            self.steps.accept(AppStep.chatIsPicked(
                roomUid: currentState.roomList[indexPath.row].channelId,
                chatRoomTitle: currentState.roomList[indexPath.row].title,
                postUploaderUid: currentState.roomList[indexPath.row].createdBy.userId,
                isFirstEntrance: false)
            )
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        
        switch mutation {
            
        case .setChatList(let rooms):
            state.roomList = sortChatListWithPendingNotificationRoomsFirst(rooms)
            
        case .setApplicationIconBadgeNumber(let badgeNumber):
            UIApplication.shared.applicationIconBadgeNumber = badgeNumber
            
        case .removeAllDeliveredNotifications:
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
        case .setNeedsToShowEmptyView(let needsToShow):
            state.needsToShowEmptyView = needsToShow
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setFetchingData(let isFetching):
            state.isFetchingData = isFetching
        }
        return state
    }
}

extension ChatListViewReactor {
    
    private func sortChatListWithPendingNotificationRoomsFirst(_ rooms: [Room]) -> [Room] {
        
        var sortedChatList: [Room] = []
        
        let chatNotificationList: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.notificationList) ?? []
        
        rooms.forEach { room in
            chatNotificationList.contains(room.channelId)
            ? sortedChatList.insert(room, at: 0)
            : sortedChatList.append(room)
        }
        return sortedChatList
    }
}
