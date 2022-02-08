//
//  StudentIdGuideReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/08.
//

import Foundation
import RxSwift
import RxRelay
import RxFlow
import ReactorKit

final class StudentIdGuideReactor: Reactor, Stepper {
    
    var steps = PublishRelay<Step>()
    
    let initialState: State
    
    enum Action {
        case finishedReadingGuide
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
        case .finishedReadingGuide:
            self.steps.accept(AppStep.studentIdVerificationIsRequired)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
