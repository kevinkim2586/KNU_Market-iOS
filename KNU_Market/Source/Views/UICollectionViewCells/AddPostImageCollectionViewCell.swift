import UIKit
import BSImagePicker
import Photos
import SnapKit

protocol AddPostImageDelegate: AnyObject {
    func didPickImagesToUpload(images: [UIImage])
}

class AddPostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    static let cellId: String = "AddPostImageCollectionViewCell"

    weak var delegate: AddPostImageDelegate!
    
    var selectedAssets: [PHAsset] = [PHAsset]()
    var userSelectedImages: [UIImage] = [UIImage]()
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let addPostImageButtonSize: CGFloat  = 80
        static let addPostImageButtonInset: CGFloat = 5
    }
    
    //MARK: - UI
    
    lazy var imagePicker: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 3
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.modalPresentationStyle = .fullScreen
        return imagePicker
    }()
    
    lazy var addPostImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add button"), for: .normal)
        button.addTarget(
            self,
            action: #selector(pressedAddButton),
            for: .touchUpInside
        )
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
        
        /// 기존 선택된 사진 모두 초기화
        selectedAssets.removeAll()
        userSelectedImages.removeAll()
        
        let vc = self.window?.rootViewController
        vc?.presentImagePicker(imagePicker, select: { (asset) in
        }, deselect: { (asset) in
        }, cancel: { (assets) in
        }, finish: { (assets) in
            
            for i in 0..<assets.count {
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetToImages()
            self.delegate?.didPickImagesToUpload(images: self.userSelectedImages)
        })
        
    }
    
    func convertAssetToImages() {
        
        if selectedAssets.count != 0 {
            
            for i in 0..<selectedAssets.count {
                
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                option.resizeMode = .exact
                
                var thumbnail = UIImage()
                
                imageManager.requestImage(
                    for: selectedAssets[i],
                    targetSize: CGSize(width: 1000, height: 1000),
                    contentMode: .aspectFit,
                    options: option
                ) { (result, _) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data!)
                
                self.userSelectedImages.append(newImage! as UIImage)
            }
        }
    }
    
}
