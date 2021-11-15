import UIKit

import Then
import ReactorKit
import RxGesture
import SnapKit
import UITextView_Placeholder
import SnapKit
import BSImagePicker
import Photos

class SendUsMessageViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = SendUsMessageReactor
    
    //MARK: - Properties
    var disposeBag: DisposeBag = DisposeBag()
    private var userManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Metric {
        // View
        static let viewSide = 20.f
        
        // title
        static let titleTop = 35.f
    }
    
    fileprivate struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static let tintFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let textFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    fileprivate struct Style {
        static let mainColor = UIColor(named: "AppDefaultColor")
    }
    
    fileprivate struct Texts {
        
    }
    
    //MARK: - UI
    let describeLabel = UILabel().then {
        $0.text = "저희에게 궁금한 점이 있거나 부탁하고싶은 점을 말해주세요!\n빠른 시일내로 답변드리겠습니다"
        $0.adjustsFontSizeToFitWidth = true
        $0.font = Fonts.titleFont
        $0.numberOfLines = 2
    }
    
    let titleLabel = UILabel().then {
        $0.text = "문의 및 건의 내용"
        $0.font = Fonts.tintFont
    }
    
    let titleTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.tintColor = Style.mainColor
        $0.placeholder = "30자 이내"
        $0.font = Fonts.textFont
    }
    
    let explainLabel = UILabel().then {
        $0.text = "상세 내용"
        $0.font = Fonts.tintFont
    }
    
    let textView = UITextView().then {
        $0.font = Fonts.textFont
        $0.layer.borderWidth = 1
        $0.tintColor = Style.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 5
        $0.placeholder = "전하고 싶은 말을 자유롭게 남겨주세요!"
    }
    
    let selectView = UIImageView().then {
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.backgroundColor = .clear
    }
    
    let firstImage = UIImageView().then {
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
    }
    
    let secondImage = UIImageView().then {
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
    }
    
    //MARK: - Initialization
    
    init(userManager: UserManager, reactor: Reactor) {
        super.init()
        self.userManager = userManager
        
        self.hidesBottomBarWhenPushed = true
        
        defer {
            self.reactor = reactor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        self.view.addSubview(self.describeLabel)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.titleTextField)
        self.view.addSubview(self.explainLabel)
        self.view.addSubview(self.textView)
        self.view.addSubview(self.selectView)
        self.view.addSubview(self.firstImage)
        self.view.addSubview(self.secondImage)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.describeLabel.snp.makeConstraints {
            $0.top.equalToSafeArea(self.view).offset(Metric.titleTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view)
                .offset(-Metric.viewSide)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.describeLabel.snp.bottom).offset(30)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(50)
        }
        
        self.explainLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(20)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.textView.snp.makeConstraints {
            $0.top.equalTo(self.explainLabel.snp.bottom).offset(10)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.selectView.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(Metric.viewSide)
            $0.height.width.equalTo(65)
        }
        
        self.firstImage.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(20)
            $0.left.equalTo(self.selectView.snp.right).offset(10)
            $0.height.width.equalTo(65)
        }
        
        self.secondImage.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(20)
            $0.left.equalTo(self.firstImage.snp.right).offset(10)
            $0.height.width.equalTo(65)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    
        self.title = "크누마켓팀과 대화하기"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Configuring
    func bind(reactor: SendUsMessageReactor) {
        self.selectView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.pickImage(currentImage: reactor.currentState.image.count)
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.image }.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                $0.enumerated().forEach {
                    if $0.0 == 0 {
                        self.firstImage.image = $0.1
                    }
                    else if $0.0 == 1 {
                        self.secondImage.image = $0.1
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    
}

//MARK: - Method
private extension SendUsMessageViewController {
    
    func convertAssetToImage(_ assets: [PHAsset]) -> [UIImage] {
        var result: [UIImage] = []
        if assets.count != 0 {
                for i in 0 ..< assets.count {
                    let imageManager = PHImageManager.default()
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        var thumbnail = UIImage()
                        imageManager.requestImage(for: assets[i], targetSize: CGSize(width: assets[i].pixelWidth, height: assets[i].pixelHeight), contentMode: .aspectFill, options: option) {
                                (result, info) in
                                thumbnail = result!
                        }
                
                        let data = thumbnail.jpegData(compressionQuality: 1)
                        let newImage = UIImage(data: data!)
                        result.append(newImage! as UIImage)
                    }
            }
        return result
    }
    
    func pickImage(currentImage: Int) {
        if currentImage == 2 {
            return
        }
        
        let imagePicker = ImagePickerController()
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.settings.selection.max = 2 - currentImage
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.theme.selectionFillColor = Style.mainColor!
        imagePicker.doneButton.tintColor = Style.mainColor
        imagePicker.cancelButton.tintColor = Style.mainColor

        presentImagePicker(imagePicker, select: {
            (asset) in
                // 사진 하나 선택할 때마다 실행되는 내용 쓰기
        }, deselect: {
            (asset) in
                // 선택했던 사진들 중 하나를 선택 해제할 때마다 실행되는 내용 쓰기
        }, cancel: {
            (assets) in
                // Cancel 버튼 누르면 실행되는 내용
            
        }, finish: {
            [weak self] (assets) in
                // Done 버튼 누르면 실행되는 내용
            guard let self = self else { return }
            Observable<[UIImage]>.just(self.convertAssetToImage(assets))
                .map { Reactor.Action.setImage($0) }
                .bind(to: self.reactor!.action )
                .disposed(by: self.disposeBag)
        })
        
        
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct SendUsMessageVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        SendUsMessageViewController(userManager: UserManager(), reactor: SendUsMessageReactor()).toPreview()
    }
}
#endif
