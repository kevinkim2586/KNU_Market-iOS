//
//  PopupReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import Foundation
import ReactorKit
import UIKit
import Moya

final class PopupReactor: Reactor {
    
    let initialState: State
    
    enum Action {
        case viewWillAppear
        case pressedPopupImage
        case doNotSeePopupForOneDay
    }
    
    enum Mutation {
        case setPopupImage(URL)
        case pressPopupImage(URL)
        case dismiss
    }
    
    struct State {
        var popupUid: Int
        var mediaUid: String
        var landingUrlString: String?
        
        var dismiss = false
        var landingUrl: URL?
        var mediaUrl: URL?
    }
    
    let popupService: PopupServiceType
    
    init(popupUid: Int, mediaUid: String, landingUrlString: String?, popupService: PopupServiceType) {
        self.initialState = State(
            popupUid: popupUid,
            mediaUid: mediaUid,
            landingUrlString: landingUrlString
        )
        self.popupService = popupService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .viewWillAppear:
            guard let url = URL(string: K.MEDIA_REQUEST_URL + currentState.mediaUid) else {
                return Observable.empty()
            }
            return Observable.just(Mutation.setPopupImage(url))
            
        case .pressedPopupImage:
            
            guard let urlString = currentState.landingUrlString, let landingUrl = URL(string: urlString) else {
                return Observable.empty()
            }
            
            return Observable.concat([
                self.popupService.incrementPopupViewCount(popupUid: currentState.popupUid)
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success:
                            print("✅ increment viewCount success")
                        case .error(let error):
                            print("❗️ increment viewCount failed: \(error)")
                        }
                    }.flatMap { _ in Observable.empty() },
                Observable.just(Mutation.pressPopupImage(landingUrl))
            ])
            
        case .doNotSeePopupForOneDay:
            
            return Observable.just(self.popupService.blockPopupForADay())
                .flatMap { _ in
                    Observable.just(Mutation.dismiss)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setPopupImage(let url):
            state.mediaUrl = url
            
        case .pressPopupImage(let url):
            state.landingUrl = url
            
        case .dismiss:
            state.dismiss = true
        }
        return state
    }
}
