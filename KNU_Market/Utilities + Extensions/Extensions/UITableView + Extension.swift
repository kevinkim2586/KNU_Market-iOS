import UIKit

extension UITableView {
    
    func showEmptyView(imageName: String, text: String) {
        
        let emptyView = EmptyView()
        emptyView.configure(imageName: imageName, text: text)
        self.backgroundView = emptyView
    }
    
    func restoreEmptyView() {
        
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
