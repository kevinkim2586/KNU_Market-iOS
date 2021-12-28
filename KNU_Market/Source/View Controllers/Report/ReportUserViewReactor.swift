//
//  ReportUserViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/27.
//


import UIKit
import RxSwift
import ReactorKit

final class ReportUserViewReactor: Reactor {
    
    let initialState: State
    let reportService: ReportServiceType
    
    enum Action {
        case updateReportContent(String)
        case sendReport
    }
    
    enum Mutation {
        case setReportContent(String)
        case setLoading(Bool)
        case setReportComplete(Bool)
        case setErrorMessage(String)
    }
    
    struct State {
        var userToReport: String
        var postUid: String?
        var reportContent: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        var reportComplete: Bool = false
    }
    
    init(reportService: ReportServiceType, userToReport: String, postUid: String? = nil) {
        self.reportService = reportService
        self.initialState = State(userToReport: userToReport, postUid: postUid)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .updateReportContent(let reportContent):
            return Observable.just(Mutation.setReportContent(reportContent))
            
        case .sendReport:
            
            if !validateReportContent() {
                return Observable.just(Mutation.setErrorMessage("신고 내용을 3글자 이상 적어주세요 👀"))
            } else {
                
                let model = ReportUserRequestDTO(
                    user: currentState.userToReport,
                    content: currentState.reportContent,
                    postUID: currentState.postUid ?? ""
                )
                
                return Observable.concat([
                    Observable.just(Mutation.setLoading(true)),
                    self.reportService.reportUser(with: model)
                        .asObservable()
                        .map { result in
                            switch result {
                            case .success:
                                return Mutation.setReportComplete(true)
                            case .error(let error):
                                return Mutation.setErrorMessage(error.errorDescription)
                            }
                        },
                    Observable.just(Mutation.setLoading(false))
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        switch mutation {
        case .setReportContent(let reportContent):
            state.reportContent = reportContent
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            
        case .setReportComplete(let reportComplete):
            state.reportComplete = reportComplete
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
        }
        return state
    }
}

extension ReportUserViewReactor {
    
    private func validateReportContent() -> Bool {
        guard !currentState.reportContent.isEmpty else {
            return false
        }
        guard currentState.reportContent.count >= 3 else {
            return false
        }
        return true
    }
}
