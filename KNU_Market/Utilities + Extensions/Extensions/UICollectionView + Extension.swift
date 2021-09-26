import UIKit

extension UICollectionView {
    
    func showEmptyChatView() {
        
        let imageIndex = Int.random(in: 0...1)
        let imageName = Constants.Images.emptyChatRandomImage[imageIndex] 
        
        let textIndex = Int.random(in: 0...2)
        let text = Constants.placeHolderTitle.emptyChatRandomTitle[textIndex]
    
        let emptyView = EmptyView()
        emptyView.configure(imageName: imageName, text: text)
        self.backgroundView = emptyView
        
    }
}
