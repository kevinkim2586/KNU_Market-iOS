import UIKit
import BSImagePicker
import Photos
import SnapKit
import Then

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
