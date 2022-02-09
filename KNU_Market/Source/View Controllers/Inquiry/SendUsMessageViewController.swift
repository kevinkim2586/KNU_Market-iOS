import UIKit

import Then
import ReactorKit
import RxGesture
import UITextView_Placeholder
import SnapKit
import BSImagePicker
import Photos

class SendUsMessageViewController: BaseViewController, ReactorKit.View {
    
    typealias Reactor = SendUsMessageReactor
    
    //MARK: - Properties

    
    //MARK: - Constants
    
    fileprivate struct Metric {
        // View
        static let viewSide = 20.f
        
        // title
        static let titleTop = 30.f
        
        static let titleTextFieldTop = 20.f
        static let titleTextFieldHeight = 50.f
        
        static let explainLabelTop = 20.f
        
        static let TextViewTop = 10.f
        
        static let imagesSize = 65.f
        static let imagesTop = 20.f
        static let imagesSide = 10.f
        
        static let ButtonButtonHeight = 80.f
        
        // Delete Button
        static let deleteButtonSize = 20.f
    }
    
    fileprivate struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static let tintFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let textFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        // Bottom Button
        static let buttonFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    fileprivate struct Style {
        static let mainColor = UIColor(named: "AppDefaultColor")
        static let cornerRadius = 5.f
        static let borderWidth = 1.f
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
    
    let barButton = UIBarButtonItem(title: "내역", style: .plain, target: nil, action: nil).then {
        $0.tintColor = Style.mainColor
    }
    
    let titleLabel = UILabel().then {
        $0.text = "문의 및 건의 내용"
        $0.font = Fonts.tintFont
    }
    
    let titleTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.layer.borderWidth = Style.borderWidth
        $0.layer.cornerRadius = Style.cornerRadius
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
        $0.layer.borderWidth = Style.borderWidth
        $0.tintColor = Style.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = Style.cornerRadius
        $0.placeholder = "전하고 싶은 말을 자유롭게 남겨주세요!"
    }
    
    let selectView = ImageSelectionView()
    
    let firstImage = UIImageView().then {
        $0.layer.borderWidth = Style.borderWidth
        $0.layer.cornerRadius = Style.cornerRadius
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
    }
    
    let firstButton = UIButton(type: .system).then {
        $0.layer.cornerRadius = Metric.deleteButtonSize / 2
        $0.backgroundColor = Style.mainColor
        $0.clipsToBounds = true
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }
    
    let secondImage = UIImageView().then {
        $0.layer.borderWidth = Style.borderWidth
        $0.layer.cornerRadius = Style.cornerRadius
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
    }
    
    let secondButton = UIButton(type: .system).then {
        $0.layer.cornerRadius = Metric.deleteButtonSize / 2
        $0.backgroundColor = Style.mainColor
        $0.clipsToBounds = true
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.white, for: .normal)
    }

    
    let buttomButton = KMButton(type: .system).then {
        $0.setTitle("전송하기", for: .normal)
        $0.setTitle("작성중", for: .disabled)
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        
        self.hidesBottomBarWhenPushed = true
        defer { self.reactor = reactor }
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
        self.view.addSubview(self.firstButton)
        self.view.addSubview(self.secondImage)
        self.view.addSubview(self.secondButton)
        self.view.addSubview(self.buttomButton)
        self.navigationItem.rightBarButtonItem = self.barButton
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
            $0.top.equalTo(self.describeLabel.snp.bottom).offset(Metric.titleTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.titleTextFieldTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(Metric.titleTextFieldHeight)
        }
        
        self.explainLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(Metric.explainLabelTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.textView.snp.makeConstraints {
            $0.top.equalTo(self.explainLabel.snp.bottom).offset(Metric.TextViewTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.selectView.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(Metric.imagesTop)
            $0.left.equalToSuperview().offset(Metric.viewSide)
            $0.height.width.equalTo(Metric.imagesSize)
        }
        
        self.firstImage.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(Metric.imagesTop)
            $0.left.equalTo(self.selectView.snp.right).offset(Metric.imagesSide)
            $0.height.width.equalTo(Metric.imagesSize)
        }
        
        self.firstButton.snp.makeConstraints {
            $0.height.width.equalTo(Metric.deleteButtonSize)
            $0.centerX.equalTo(self.firstImage.snp.right)
            $0.centerY.equalTo(self.firstImage.snp.top)
        }
        
        self.secondImage.snp.makeConstraints {
            $0.top.equalTo(self.textView.snp.bottom).offset(Metric.imagesTop)
            $0.left.equalTo(self.firstImage.snp.right).offset(Metric.imagesSide)
            $0.height.width.equalTo(Metric.imagesSize)
        }
        
        self.secondButton.snp.makeConstraints {
            $0.height.width.equalTo(Metric.deleteButtonSize)
            $0.centerX.equalTo(self.secondImage.snp.right)
            $0.centerY.equalTo(self.secondImage.snp.top)
        }
        
        self.buttomButton.snp.makeConstraints {
            $0.left.right.equalToSafeArea(self.view)
            $0.height.equalTo(Metric.ButtonButtonHeight)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    
        self.title = "크누마켓팀과 대화하기"
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Configuring
    func bind(reactor: SendUsMessageReactor) {
        self.titleTextField.rx.text.orEmpty.asObservable()
            .map { Reactor.Action.updateTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.textView.rx.text.orEmpty.asObservable()
            .map { Reactor.Action.updateContent($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.selectView.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.pickImage(currentImage: reactor.currentState.image.count)
            }).disposed(by: disposeBag)
        
        self.firstButton.rx.tap.asObservable()
            .map { Reactor.Action.deleteImage(0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.secondButton.rx.tap.asObservable()
            .map { Reactor.Action.deleteImage(1) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.buttomButton.rx.tap.asObservable()
            .map { Reactor.Action.sendMessage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.barButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(InquiryListViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        self.titleTextField.rx.text.orEmpty.map { !$0.isEmpty }.asObservable()
        .bind(to: self.buttomButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        reactor.state.map { $0.image }.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.firstImage.image = nil
                self.firstButton.isHidden = true
                self.secondImage.image = nil
                self.secondButton.isHidden = true
                
                $0.enumerated().forEach {
                    if $0.0 == 0 {
                        self.firstImage.image = $0.1
                        self.firstButton.isHidden = false
                    }
                    else if $0.0 == 1 {
                        self.secondImage.image = $0.1
                        self.secondButton.isHidden = false
                    }
                }
                
            }).disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: {
                $0 ? showProgressBar() : dismissProgressBar()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.dismiss }.filter { $0 }.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.showSimpleBottomAlert(with: "문의사항이 전송 완료되었어요 🎉")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { "\($0.image.count)/2" }.asObservable()
            .bind(to: self.selectView.label.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.title }.asObservable()
            .bind(to: self.titleTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    
}

//MARK: - Method
private extension SendUsMessageViewController {
    
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
            Observable<[UIImage]>.just(AssetConverter.convertAssetToImage(assets))
                .map { Reactor.Action.setImage($0) }
                .bind(to: self.reactor!.action )
                .disposed(by: self.disposeBag)
        })
    }
}
