//
//  MyPageCellReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import ReactorKit
import RxCocoa

final class MyPageCellReactor: Reactor {
    
    typealias Action = NoAction
    
    let initialState: MyPageTableViewCellModel
    
    init(state: MyPageTableViewCellModel) {
        self.initialState = state
    }
}
