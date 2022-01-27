import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol UserPickedPostImageDelegate: AnyObject {
    func didPressDelete(at index: Int)
}

class UserPickedPostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let cellId: String = "UserPickedPostImageCollectionViewCell"
    
    let disposeBag = DisposeBag()
    
    weak var delegate: UserPickedPostImageDelegate?

    let tapGesture = PublishSubject<Int>()
    
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
        button.setImage(UIImage(named: "delete button"), for: .normal)
        return button
    }()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
        bindUI()
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
    
    private func bindUI() {
        deleteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.delegate?.didPressDelete(at: self.indexPath)
            })
            .disposed(by: disposeBag)
    }
}
