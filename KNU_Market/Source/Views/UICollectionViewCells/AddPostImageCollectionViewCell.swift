import UIKit
import BSImagePicker
import Photos
import SnapKit
import Then
import YPImagePicker

protocol AddPostImageDelegate: AnyObject {
    func didPickImagesToUpload(images: [UIImage])
}

class AddPostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let cellId: String = "AddPostImageCollectionViewCell"

    weak var delegate: AddPostImageDelegate!
    
    var userSelectedImages: [UIImage] = [UIImage]()
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let addPostImageButtonSize: CGFloat  = 80
        static let addPostImageButtonInset: CGFloat = 5
    }
    
    //MARK: - UI
    
    fileprivate lazy var imagePicker = ImagePickerController().then {
        $0.settings.selection.max = 3
        $0.doneButtonTitle = "완료"
        $0.settings.theme.selectionFillColor = UIColor.init(named: K.Color.appColor) ?? .systemBlue
        $0.doneButton.tintColor = UIColor.init(named: K.Color.appColor)
        $0.cancelButton.tintColor = UIColor.init(named: K.Color.appColor)
        $0.settings.fetch.assets.supportedMediaTypes = [.image]
        $0.modalPresentationStyle = .fullScreen
    }
    
    private lazy var addPostImageButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "add button"), for: .normal)
        $0.addTarget(
            self,
            action: #selector(pressedAddButton),
            for: .touchUpInside
        )
    }
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        contentView.addSubview(addPostImageButton)
    }
    
    private func setupConstraints() {
    
        addPostImageButton.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.addPostImageButtonSize)
            $0.edges.equalToSuperview().inset(Metrics.addPostImageButtonInset)
        }
    }
    
    //MARK: - Target Methods

    @objc private func pressedAddButton() {
        
        
        var config = YPImagePickerConfiguration()
        config.showsCrop = .rectangle(ratio: 1.0)
        config.screens = [.library]
        config.library.maxNumberOfItems = 5
        config.showsPhotoFilters = false
//        config.colors.tintColor = UIColor(named: K.Color.appColor)!
        
        let picker = YPImagePicker(configuration: config)
   
        let vc = self.window?.rootViewController
        vc?.present(picker, animated: true, completion: nil)
    
        picker.didFinishPicking { items, _ in
            self.userSelectedImages.removeAll()         //기존에 선택된 사진 삭제
            for item in items {
                switch item {
                case .photo(let photo):
                    self.userSelectedImages.append(photo.image)
                default: break
                }
            }
            self.delegate?.didPickImagesToUpload(images: self.userSelectedImages)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
