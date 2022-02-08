//
//  VerifyOptionViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/08.
//

import Foundation
import RxSwift
import ReactorKit
import RxRelay
import RxFlow

final class VerifyOptionViewReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    
    enum Action {
        case verifyUsingStudentId
        case verifyUsingSchoolEmail
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    init() {
        self.initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .verifyUsingStudentId:

            return .empty()
            
        case .verifyUsingSchoolEmail:
            
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
