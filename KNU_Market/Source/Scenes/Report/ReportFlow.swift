//
//  ReportFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/09.
//

import Foundation
import RxFlow

class ReportFlow: Flow {
    
    private let reportService: ReportServiceType
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: ReportUserViewController
    
    init(reportService: ReportServiceType, userToReport: String, postUid: String?) {
        self.reportService = reportService
        
        let reactor = ReportUserViewReactor(
            reportService: reportService,
            userToReport: userToReport,
            postUid: postUid ?? ""
        )
        let vc = ReportUserViewController(reactor: reactor)
        vc.modalPresentationStyle = .overFullScreen
        
        self.rootViewController = vc
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .reportIsRequired:
            return presentReportView()
            
        case .reportIsCompleted:
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.rootViewController.dismiss(animated: true, completion: nil)
            }
            return .none
            
        default :
            return .none
        }
    }
}

extension ReportFlow {
    
    private func presentReportView() -> FlowContributors {
        return .one(flowContributor: .contribute(withNextPresentable: rootViewController, withNextStepper: rootViewController.reactor!))
    }
}
