import UIKit
import Photos
import SnapKit
import Then
import YPImagePicker
import RxSwift
import RxCocoa
import RxGesture

protocol AddPostImageDelegate: AnyObject {
    func didPickImagesToUpload(images: [UIImage])
}

class AddPostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let cellId: String = "AddPostImageCollectionViewCell"
    
    let disposeBag = DisposeBag()
    
    let userPickedImages = BehaviorSubject<[UIImage]>(value: [])
    
    weak var delegate: AddPostImageDelegate!
    
    var userSelectedImages: [UIImage] = [UIImage]()
    
    let maxNumberOfImagesAllowed: Int = 5
    
    lazy var imagePickerConfiguration: YPImagePickerConfiguration = {
        var config = YPImagePickerConfiguration()
        config.showsCrop = .rectangle(ratio: 1.0)
        config.screens = [.library]
        config.library.maxNumberOfItems = maxNumberOfImagesAllowed
        config.showsPhotoFilters = false
        return config
    }()
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let addPostImageButtonSize: CGFloat  = 80
        static let addPostImageButtonInset: CGFloat = 5
    }
    
    //MARK: - UI
        
    let addPostImageView = ImageSelectionView()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
        configure()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        contentView.addSubview(addPostImageView)
    }
    
    private func setupConstraints() {
        addPostImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.addPostImageButtonSize)
            $0.edges.equalToSuperview().inset(Metrics.addPostImageButtonInset)
        }
    }
    
    private func configure() {
        addPostImageView.label.text = "(0/\(maxNumberOfImagesAllowed))"
    }
    
    private func bind() {
        addPostImageView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.presentImagePicker()
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Target Methods
    
    private func presentImagePicker() {

        let picker = YPImagePicker(configuration: imagePickerConfiguration)
   
        let vc = self.window?.rootViewController
        vc?.present(picker, animated: true, completion: nil)
    
        picker.didFinishPicking { items, _ in
            self.userSelectedImages.removeAll()         //기존에 선택된 사진 삭제
            self.addPostImageView.label.text = "(\(items.count)/\(self.maxNumberOfImagesAllowed))"
            for item in items {
                switch item {
                case .photo(let photo):
                    self.userSelectedImages.append(photo.image)
                default: break
                }
            }
            self.userPickedImages.onNext(self.userSelectedImages)
            self.delegate?.didPickImagesToUpload(images: self.userSelectedImages)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
