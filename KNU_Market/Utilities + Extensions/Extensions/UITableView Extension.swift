import UIKit

extension UITableView {
    
    func showEmptyView(imageName: String, text: String) {
        
        let emptySearchView = EmptySearchView()
        emptySearchView.configure(imageName: imageName, text: text)

        self.backgroundView = emptySearchView
    }
    
    func restoreEmptyView() {
        
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
