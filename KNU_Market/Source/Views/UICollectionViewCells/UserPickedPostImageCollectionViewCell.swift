import UIKit
import SnapKit

protocol UserPickedPostImageCellDelegate: AnyObject {
    func didPressDeleteImageButton(at index: Int)
}

class UserPickedPostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let cellId: String = "UserPickedPostImageCollectionViewCell"
    
    weak var delegate: UserPickedPostImageCellDelegate!
    var indexPath: Int!
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let userPickedImageSize: CGFloat     = 80
        static let userPickedImageInset: CGFloat    = 5
        static let deleteButtonSize: CGFloat        = 25
    }
    
    //MARK: - UI
    
    lazy var userPickedPostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(pressedDeleteButton),
            for: .touchUpInside
        )
        button.setImage(UIImage(named: "delete button"), for: .normal)
        return button
    }()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - UI Configuration
    
    private func setupLayout() {
        contentView.addSubview(userPickedPostImageView)
        contentView.addSubview(deleteButton)
    }
    
    private func setupConstraints() {
        
        userPickedPostImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Metrics.userPickedImageInset)
            $0.width.height.equalTo(Metrics.userPickedImageSize)
        }
        
        deleteButton.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.deleteButtonSize)
            $0.top.right.equalToSuperview()
        }
    }
    
    //MARK: - Target Methods
    
    @objc private func pressedDeleteButton() {
        delegate.didPressDeleteImageButton(at: indexPath)
    }
}
