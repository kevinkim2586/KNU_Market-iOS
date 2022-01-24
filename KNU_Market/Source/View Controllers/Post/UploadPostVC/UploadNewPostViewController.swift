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
import UITextView_Placeholder

class UploadNewPostViewController: BaseViewController, ReactorKit.View {

    
    typealias Reactor = UploadNewPostReactor
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    struct Texts {
        static let textViewPlaceholder: String = "공구 내용을 작성해주세요. 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다."
    }
    
    struct Fonts {
        static let priceTextField: UIFont   = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)!
        static let guideLabel: UIFont       = UIFont(name: K.Fonts.notoSansKRBold, size: 16)!
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
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
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
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
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
        $0.text = "(본인포함)"
        $0.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 11)
        $0.textColor = .lightGray
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.85
    }
    
    let gatheringPeopleTextField = UITextField().then {
        $0.placeholder = "0"
        $0.textAlignment = .right
        $0.font = Fonts.guideLabel
        $0.tintColor = Colors.appColor
        $0.keyboardType = .numberPad
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumFontSize = 12
    }
    
    let peopleUnitLabel = UILabel().then {
        $0.text = "명"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
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
        
        
        // Output
        
        /// 제품 가격
        reactor.state
            .map { $0.price }
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .map { Int($0!) ?? 0 }
            .map { $0.withDecimalSeparator }
            .bind(to: priceTextField.rx.text)
            .disposed(by: disposeBag)
      
        /// 배송비
        reactor.state
            .map { $0.shippingFee }
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .map { Int($0) ?? 0 }
            .map { $0.withDecimalSeparator }
            .bind(to: shippingFeeTextField.rx.text)
            .disposed(by: disposeBag)
        
        // 모집 인원
        reactor.state
            .map { $0.totalGatheringPeople }
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .bind(to: gatheringPeopleTextField.rx.text)
            .disposed(by: disposeBag)
        
//        Observable.combineLatest(
//
//        )
//

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
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AddPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? AddPostImageCollectionViewCell else { fatalError() }
           
            return cell
        }
        else {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserPickedPostImageCollectionViewCell.cellId,
                for: indexPath
            ) as? UserPickedPostImageCollectionViewCell else { fatalError() }
            
            cell.indexPath = indexPath.item
            cell.userPickedPostImageView.image = UIImage(named: K.Images.defaultAvatar)
            return cell
        }
    }
    
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct UploadNEWPostVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        UploadNewPostViewController(reactor: UploadNewPostReactor(postService: PostService(network: Network<PostAPI>()), mediaService: MediaService(network: Network<MediaAPI>()))).toPreview()
    }
}
#endif
