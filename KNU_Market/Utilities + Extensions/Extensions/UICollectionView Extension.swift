import UIKit

extension UICollectionView {
    
    func showEmptyChatView() {
        
        let index = Int.random(in: 0...1)
        let imageName = Constants.Images.emptyChatRandomImage[index]
        let text = Constants.placeHolderTitle.emptyChatRandomTitle[index]
    
        let emptyView = EmptyView()
        emptyView.configure(imageName: imageName, text: text)
        self.backgroundView = emptyView
        
    }
}
