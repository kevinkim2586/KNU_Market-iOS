import Foundation
import MessageKit

//MARK: - ChatVC 내에서 이미지 주고 받을 때 필요한 구조체

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
