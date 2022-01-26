//
//  UploadNewPostViewController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/22.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import YPImagePicker
import UITextView_Placeholder

class UploadNewPostViewController: BaseViewController, ReactorKit.View {

    
    typealias Reactor = UploadNewPostReactor
    
    //MARK: - Properties
    
    private let minimumRequiredPeople: Int = 2
    
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
    
    struct Texts {
        static let textViewPlaceholder: String = "공구 내용을 작성해주세요. 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다."
    }
    
    struct Fonts {
        static let priceTextField: UIFont   = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)!
        static let guideLabel: UIFont       = UIFont(name: K.Fonts.notoSansKRBold, size: 16)!
        static let unitLabel: UIFont        = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)!
        static let urlTextField: UIFont     = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)!
        static let detailTextView: UIFont   = UIFont(name: K.Fonts.notoSansKRMedium, size: 14)!
    }
    
    struct Colors {
        static let dividerLineColor: UIColor    = UIColor.convertUsingHexString(hexValue: "#E9E9E9")
        static let appColor: UIColor            = UIColor(named: K.Color.appColor)!
        static let unitLabel: UIColor           = UIColor.convertUsingHexString(hexValue: "#4A4A4A")
    }
    
    struct Metrics {
        static let defaultSideInset     = 20.f
        static let guideLabelSideInset  = 20.f
        static let textFieldSideInset   = 25.f
        static let topOffset            = 20.f
        static let dividerLineInset     = 25.f
    }
    
    //MARK: - UI
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    
    lazy var postScrollView = UIScrollView(frame: .zero).then {
        $0.frame = self.view.bounds
        $0.contentSize = contentViewSize
        $0.clipsToBounds = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
        $0.autoresizingMask = .flexibleHeight
    }
    
    lazy var contentView = UIView().then {
        $0.backgroundColor = .white
        $0.frame.size = contentViewSize
    }
    
    let layout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 10
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.itemSize = CGSize(width: 80, height: 80)
    }
    
    lazy var postImagesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            AddPostImageCollectionViewCell.self,
            forCellWithReuseIdentifier: AddPostImageCollectionViewCell.cellId
        )
        $0.register(
            UserPickedPostImageCollectionViewCell.self,
            forCellWithReuseIdentifier: UserPickedPostImageCollectionViewCell.cellId
        )
        $0.showsHorizontalScrollIndicator = true
        $0.isScrollEnabled = true
        $0.alwaysBounceHorizontal = true
        $0.clipsToBounds = true
        $0.backgroundColor = .clear
    }
    
    // 제품명
    
    let postTitleGuideLabel = UploadPostGuideLabel(indicatorIsRequired: true, labelTitle: "제품명")
    
    let postTitleTextField = UITextField().then {
        $0.placeholder = "ex. 다우니 섬유유연제 1.05L"
        $0.font = Fonts.priceTextField
        $0.tintColor = Colors.appColor
    }
    
    let dividerLine_1 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    /// 제품 가격
    
    let priceGuideLabel = UploadPostGuideLabel(indicatorIsRequired: true, labelTitle: "제품 가격")
    
    let priceTextField = UITextField().then {
        $0.placeholder = "0"
        $0.textAlignment = .right
        $0.font = Fonts.guideLabel
        $0.tintColor = Colors.appColor
        $0.keyboardType = .numberPad
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
    }
    
    let priceWonLabel = UILabel().then {
        $0.text = "원"
        $0.font = Fonts.unitLabel
        $0.textColor = Colors.unitLabel
    }
    
    let priceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    let dividerLine_2 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    /// 배송비
    
    let shippingFeeGuideLabel = UploadPostGuideLabel(indicatorIsRequired: false, labelTitle: "배송비")
    
    let shippingFeeTextField = UITextField().then {
        $0.placeholder = "0"
        $0.font = Fonts.guideLabel
        $0.textAlignment = .right
        $0.tintColor = Colors.appColor
        $0.keyboardType = .numberPad
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
    }
    
    let shippingFeeWonLabel = UILabel().then {
        $0.text = "원"
        $0.font = Fonts.unitLabel
        $0.textColor = Colors.unitLabel
    }
    
    let shippingFeeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    let dividerLine_3 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    /// 인원
    
    let totalGatheringPeopleGuideLabel = UploadPostGuideLabel(indicatorIsRequired: true, labelTitle: "인원")
    
    let includingSelfLabel = UILabel().then {
        $0.text = "(2~10명)"
        $0.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 11)
        $0.textColor = .lightGray
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.85
    }
    
    let gatheringPeopleTextField = UITextField().then {
        $0.placeholder = "2"
        $0.textAlignment = .right
        $0.font = Fonts.guideLabel
        $0.tintColor = Colors.appColor
        $0.keyboardType = .numberPad
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
    }
    
    let peopleUnitLabel = UILabel().then {
        $0.text = "명"
        $0.font = Fonts.unitLabel
        $0.textColor = Colors.unitLabel
    }
    
    let totalGatheringPeopleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    let dividerLine_4 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    /// 1인당 가격 Label
    
    let perPersonLabel = UILabel().then {
        $0.text = "1인당"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
        $0.textColor = UIColor.convertUsingHexString(hexValue: "#515151")
    }
    
    let pricePerPersonLabel = UILabel().then {
        $0.text = "0"
        $0.font = UIFont(name: K.Fonts.robotoBold, size: 26)
        $0.textColor = .black
    }
    
    let wonLabel = UILabel().then {
        $0.text = "원"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
        $0.textColor = UIColor.convertUsingHexString(hexValue: "#515151")
    }
    
    let perPersonPriceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = 5
    }
    
    /// 상품 URL
    
    let referenceUrlGuideLabel = UploadPostGuideLabel(indicatorIsRequired: false, labelTitle: "상품 URL")
    
    let referenceUrlTextField = UITextField().then {
        $0.placeholder = "ex. https://www.coupang.com"
        $0.tintColor = Colors.appColor
        $0.font = Fonts.urlTextField
        $0.autocapitalizationType = .none
    }
    
    let dividerLine_5 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    /// 공구 상세설명
    
    let postDetailGuideLabel = UploadPostGuideLabel(indicatorIsRequired: true, labelTitle: "상세설명")
    
    let horizontalLine = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let postDetailTextView = UITextView().then {
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.placeholder = Texts.textViewPlaceholder
        $0.tintColor = Colors.appColor
        $0.font = Fonts.detailTextView
    }
    
    let doneButton = KMShadowButton(buttonTitle: "완료").then {
        $0.setTitle("완료", for: .normal)
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "공구글 올리기"
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(postScrollView)
        postScrollView.addSubview(contentView)
        contentView.addSubview(postImagesCollectionView)
        
        // 제품명
        contentView.addSubview(postTitleGuideLabel)
        contentView.addSubview(postTitleTextField)
        contentView.addSubview(dividerLine_1)
        
        // 제품가격
        contentView.addSubview(priceGuideLabel)
        [priceTextField, priceWonLabel].forEach {
            priceStackView.addArrangedSubview($0)
        }
        contentView.addSubview(priceStackView)
        contentView.addSubview(dividerLine_2)
        
        // 배송비
        contentView.addSubview(shippingFeeGuideLabel)
        [shippingFeeTextField, shippingFeeWonLabel].forEach {
            shippingFeeStackView.addArrangedSubview($0)
        }
        contentView.addSubview(shippingFeeStackView)
        contentView.addSubview(dividerLine_3)
        
        /// 모집 인원
        contentView.addSubview(totalGatheringPeopleGuideLabel)
        contentView.addSubview(includingSelfLabel)
        [gatheringPeopleTextField, peopleUnitLabel].forEach {
            totalGatheringPeopleStackView.addArrangedSubview($0)
        }
        contentView.addSubview(totalGatheringPeopleStackView)
        contentView.addSubview(dividerLine_4)
        
        /// 1인당 가격
        [perPersonLabel, pricePerPersonLabel, wonLabel].forEach {
            perPersonPriceStackView.addArrangedSubview($0)
        }
        contentView.addSubview(perPersonPriceStackView)
        
        /// 상품 URL
        contentView.addSubview(referenceUrlGuideLabel)
        contentView.addSubview(referenceUrlTextField)
        contentView.addSubview(dividerLine_5)
        
        /// 공구 상세설명
        contentView.addSubview(postDetailGuideLabel)
        contentView.addSubview(horizontalLine)
        contentView.addSubview(postDetailTextView)
        contentView.addSubview(doneButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.centerX.top.bottom.equalToSuperview()
        }
        
        /// Image Collection View
        postImagesCollectionView.snp.makeConstraints {
            $0.height.equalTo(135)
            $0.top.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.defaultSideInset - 5)
        }
        
        /// 제품명
        postTitleGuideLabel.snp.makeConstraints {
            $0.top.equalTo(postImagesCollectionView.snp.bottom).offset(10)
            $0.left.equalToSuperview().inset(Metrics.guideLabelSideInset)
            $0.width.greaterThanOrEqualTo(50)
        }

        postTitleTextField.snp.makeConstraints {
            $0.top.equalTo(postTitleGuideLabel.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.textFieldSideInset)
        }

        dividerLine_1.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(postTitleTextField.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 제품 가격
        priceGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_1.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalToSuperview().inset(Metrics.guideLabelSideInset)
            $0.width.greaterThanOrEqualTo(60)
        }
        
        priceStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_1.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalTo(priceGuideLabel.snp.right).offset(20)
            $0.right.equalToSuperview().offset(-100)
        }
        
        dividerLine_2.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(priceStackView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 배송비
        shippingFeeGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_2.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalToSuperview().inset(Metrics.guideLabelSideInset + 10)
            $0.width.greaterThanOrEqualTo(60)
        }
        
        shippingFeeStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_2.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalTo(shippingFeeGuideLabel.snp.right).offset(20)
            $0.right.equalToSuperview().offset(-100)
        }
        
        dividerLine_3.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(shippingFeeStackView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 모집 인원
        totalGatheringPeopleGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_3.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalToSuperview().inset(Metrics.guideLabelSideInset)
            $0.width.greaterThanOrEqualTo(40)
        }
        
        includingSelfLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_3.snp.bottom).offset(Metrics.topOffset + 5)
            $0.left.equalTo(totalGatheringPeopleGuideLabel.snp.right).offset(3)
            $0.width.equalTo(60)
        }
        
        totalGatheringPeopleStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_3.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalTo(includingSelfLabel.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-100)
        }
        
        dividerLine_4.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(totalGatheringPeopleStackView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 1인당 가격
        perPersonPriceStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_4.snp.bottom).offset(Metrics.topOffset)
            $0.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 상품 URL
        referenceUrlGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_4.snp.bottom).offset(Metrics.topOffset + 36)
            $0.left.equalToSuperview().inset(Metrics.defaultSideInset + 10)
        }
        
        referenceUrlTextField.snp.makeConstraints {
            $0.top.equalTo(referenceUrlGuideLabel.snp.bottom).offset(Metrics.topOffset)
            $0.left.right.equalToSuperview().inset(Metrics.textFieldSideInset + 5)
        }
        
        dividerLine_5.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(referenceUrlTextField.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.dividerLineInset)
        }
        
        /// 공구 상세설명
        postDetailGuideLabel.snp.makeConstraints {
            $0.top.equalTo(dividerLine_5.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalToSuperview().inset(Metrics.guideLabelSideInset)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        horizontalLine.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalTo(postDetailGuideLabel.snp.bottom).offset(Metrics.topOffset)
            $0.height.equalTo(200)
            $0.left.equalToSuperview().inset(Metrics.defaultSideInset)
        }
   
        postDetailTextView.snp.makeConstraints {
            $0.top.equalTo(postDetailGuideLabel.snp.bottom).offset(Metrics.topOffset - 5)
            $0.left.equalTo(horizontalLine.snp.right).offset(5)
            $0.right.equalToSuperview().inset(Metrics.defaultSideInset)
            $0.height.equalTo(200)
        }
        
        doneButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview().inset(Metrics.defaultSideInset)
            $0.top.equalTo(postDetailTextView.snp.bottom).offset(Metrics.topOffset)
            $0.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - Binding
    
    func bind(reactor: UploadNewPostReactor) {
        
        // Input
        
        postTitleTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateTitle($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        priceTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updatePrice($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        shippingFeeTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateShippingFee($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        gatheringPeopleTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateGatheringPeople($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        referenceUrlTextField.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updateReferenceUrl($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postDetailTextView.rx.text.orEmpty
            .asObservable()
            .map { Reactor.Action.updatePostDetail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .map { Reactor.Action.pressedUploadPost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        
        // Output
        
        reactor.state
            .map { $0.images }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.postImagesCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        /// 제품명
        reactor.state
            .map { $0.title }
            .filter { $0 != nil }
            .bind(to: postTitleTextField.rx.text)
            .disposed(by: disposeBag)
        
        /// 제품 가격
        reactor.state
            .map { $0.price }
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .map { price -> Int in
                guard let price = price else { return 0 }
                return Int(price) ?? 0
            }
            .map { priceInteger -> String in
                return priceInteger.withDecimalSeparator
            }
            .bind(to: priceTextField.rx.text)
            .disposed(by: disposeBag)
        
        
        /// 배송비
        reactor.state
            .map { $0.shippingFee }
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .map { shippingFee -> Int in
                guard let shippingFee = shippingFee else { return 0 }
                return Int(shippingFee) ?? 0
            }
            .map { shippingInteger -> String in
                return shippingInteger.withDecimalSeparator
            }
            .bind(to: shippingFeeTextField.rx.text)
            .disposed(by: disposeBag)


        /// 모집 인원

        reactor.state
            .map { $0.totalGatheringPeople }
            .debounce(.milliseconds(700), scheduler: MainScheduler.instance)
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .withUnretained(self)
            .subscribe(onNext: { (_, gatheringPeople) in
                // 모집 인원이 Valid하지 않으면 그냥 2로 초기화
                let isValidGatheringPeople = gatheringPeople!.isValidGatheringPeopleNumber
                
                self.gatheringPeopleTextField.text = isValidGatheringPeople == .correct
                ? gatheringPeople
                : "2"
            })
            .disposed(by: disposeBag)
        
        
        /// 1인당 가격
        
        reactor.state
            .map { [$0.price, $0.shippingFee, $0.totalGatheringPeople] }
            .map { infoStringArray -> [String] in
                let unwrappedArray: [String] = infoStringArray.map { $0 ?? "0" }
                return unwrappedArray
            }
            .map { unwrappedArray -> [Int] in
                let arrayInIntegers: [Int] = unwrappedArray.map { Int($0) ?? 0 }
                return arrayInIntegers
            }
            .map { [weak self] infoArray -> Int in
                guard let self = self else { return 0 }
                let price: Int          = infoArray[0]
                let shippingFee: Int    = infoArray[1]
                let people: Int         = infoArray[2] == 0 ? self.minimumRequiredPeople : infoArray[2]
                let perPersonPrice: Int = (price + shippingFee) / people
                return perPersonPrice
            }
            .map { $0.withDecimalSeparator }
            .bind(to: pricePerPersonLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 참고 링크
        
        reactor.state
            .map { $0.referenceUrl }
            .filter { $0 != nil }
            .bind(to: referenceUrlTextField.rx.text)
            .disposed(by: disposeBag)
        
        /// 상세설명
        
        reactor.state
            .map { $0.postDetail }
            .filter { $0 != nil }
            .bind(to: postDetailTextView.rx.text)
            .disposed(by: disposeBag)
        
        /// 완료 버튼 활성화 여부 파악
        
        let isValidPostTitle = reactor.state
            .map { $0.title ?? "" }
            .asObservable()
            .map { title -> ValidationError.OnUploadPost in
                return title.isValidPostTitle
            }
        
        let isValidPostDetail = reactor.state
            .map { $0.postDetail ?? "" }
            .asObservable()
            .map { detail -> ValidationError.OnUploadPost in
                return detail.isValidPostDetail
            }
        
        let isValidPrice = reactor.state
            .map { $0.price ?? "" }
            .asObservable()
            .map { price -> ValidationError.OnUploadPost in
                return price.isValidPostPrice
            }
        
        let isValidGatheringPeople = reactor.state
            .map { $0.totalGatheringPeople ?? "" }
            .asObservable()
            .map { gatheringPeople -> ValidationError.OnUploadPost in
                return gatheringPeople.isValidGatheringPeopleNumber
            }

        Observable.combineLatest(
            isValidPostTitle,
            isValidPostDetail,
            isValidPrice,
            isValidGatheringPeople,
            resultSelector: { (isValidPostTitle, isValidPostDetail, isValidPrice, isValidGatheringPeople) -> Bool in
                
                guard
                    isValidPostTitle == .correct,
                    isValidPostDetail == .correct,
                    isValidPrice == .correct,
                    isValidGatheringPeople == .correct
                else { return false }
                return true
            }
        )
            .bind(to: doneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        /// Divider Line 색상 변경
        
        postTitleTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_1.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        postTitleTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_1.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)
        
        priceTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_2.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        priceTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_2.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)
        
        shippingFeeTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_3.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        shippingFeeTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_3.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)
        
        gatheringPeopleTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_4.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        gatheringPeopleTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_4.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)
        
        referenceUrlTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_5.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        referenceUrlTextField.rx.controlEvent([.editingDidEnd])
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.dividerLine_5.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)
        
        postDetailTextView.rx.didBeginEditing
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.horizontalLine.backgroundColor = UIColor.black
            })
            .disposed(by: disposeBag)
        
        postDetailTextView.rx.didEndEditing
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.horizontalLine.backgroundColor = Colors.dividerLineColor
            })
            .disposed(by: disposeBag)


        reactor.state
            .map { $0.isLoading }
            .withUnretained(self)
            .subscribe(onNext: { (_, isLoading) in
                isLoading ? showProgressBar() : dismissProgressBar()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, errorMessage) in
                self.showSimpleBottomAlert(with: errorMessage!)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.didCompleteUpload }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                NotificationCenterService.updatePostList.post()
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isCompletedImageUpload }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.reactor?.action.onNext(.uploadPost)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { ($0.editPostModel) }
            .filter { $0 != nil }
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { (_, model) in
                
                print("✅ edit post model is not nil: \(model)")
                
                
                self.reactor?.action.onNext(.configurePageWithEditModel)
                
                
                
                
            })
            .disposed(by: disposeBag)
            

        // Notification Center
        
        NotificationCenterService.presentVerificationNeededAlert.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.presentUserVerificationNeededAlert()
            }
            .disposed(by: disposeBag)
    }
}

extension UploadNewPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        guard let imageCount = self.reactor?.currentState.images.count else { return 1 }
        return imageCount + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? AddPostImageCollectionViewCell else { fatalError() }
            
            cell.addPostImageView.rx.tapGesture()
                .when(.recognized)
                .withUnretained(self)
                .subscribe(onNext: { _ in
                    self.presentImagePicker()
                })
                .disposed(by: disposeBag)
            
            reactor?.state
                .map { $0.images.count }
                .map { "(\($0)/5)" }
                .bind(to: cell.addPostImageView.label.rx.text)
                .disposed(by: disposeBag)
            
            return cell
        }

        else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserPickedPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? UserPickedPostImageCollectionViewCell else { fatalError() }
            
            cell.indexPath = indexPath.item
            cell.delegate = self
            guard let imageCount = self.reactor?.currentState.images.count else { return cell }
        
            if imageCount > 0 {
                cell.userPickedPostImageView.image = self.reactor?.currentState.images[indexPath.item - 1]
            }
            return cell
        }
    }
}

//MARK: - UserPickedPostImageDelegate

extension UploadNewPostViewController: UserPickedPostImageDelegate {
    
    func didPressDelete(at index: Int) {
        self.reactor?.action.onNext(.deleteImages(index - 1))
    }
    
    private func presentImagePicker() {

        let picker = YPImagePicker(configuration: imagePickerConfiguration)

        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                picker.dismiss(animated: true)
            }
         
            var userSelectedImages: [UIImage] = []
            for item in items {
                switch item {
                case .photo(let photo):
                    userSelectedImages.append(photo.image)
                default: break
                }
            }
            self.reactor?.action.onNext(.updateImages(userSelectedImages))
            picker.dismiss(animated: true, completion: nil)
        }
        
        self.present(picker, animated: true, completion: nil)
    }
}
