import UIKit

extension UITableView {
    
    func showEmptyView(with message: String) {
        
    
        let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0,
                                                          y: 0,
                                                          width: self.bounds.size.width,
                                                          height: self.bounds.size.height))
        noDataLabel.text          = message
        noDataLabel.textColor     = UIColor.black
        noDataLabel.textAlignment = .center
        self.backgroundView  = noDataLabel
        self.separatorStyle  = .none
    }
}
