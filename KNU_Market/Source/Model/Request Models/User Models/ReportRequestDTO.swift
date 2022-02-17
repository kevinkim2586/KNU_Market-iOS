import Foundation

struct ReportRequestDTO {
    
    let type: ReportType
    let title: String
    let content: String
    let reportTo: String
    let reportFiles: [Data]?
    
    init(type: ReportType, title: String, content: String, reportTo: String, reportFiles: [Data]?) {
        self.type = type
        self.title = title
        self.content = content
        self.reportTo = reportTo
        
        if let reportFiles = reportFiles {
            self.reportFiles = reportFiles
        } else {
            self.reportFiles = nil
        }
    }
}
