import UIKit

extension UICollectionView {
    
    func showEmptyChatView() {
        
        let imageIndex = Int.random(in: 0...1)
        let imageName = K.Images.emptyChatRandomImage[imageIndex] 
        
        let textIndex = Int.random(in: 0...2)
        let text = K.placeHolderTitle.emptyChatRandomTitle[textIndex]
    
        let emptyView = EmptyView()
        emptyView.configure(imageName: imageName, text: text)
        self.backgroundView = emptyView
        
    }
}
