import UIKit

protocol UserPickedItemImageCellDelegate: AnyObject {
    func didPressDeleteImageButton(at index: Int)
}

// 사용자가 고른 이미지가 표시되는 Collection View Cell

class UserPickedItemImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userPickedImageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: UserPickedItemImageCellDelegate!
    
    var indexPath: Int = 0
    
    
    
    @IBAction func pressedCancelButton(_ sender: UIButton) {
        delegate?.didPressDeleteImageButton(at: indexPath)
    }
    
}
