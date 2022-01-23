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
        
        static let guideLabel: UIFont = UIFont(name: K.Fonts.notoSansKRRegular, size: 15)!
    }
    
    struct Colors {
        static let dividerLineColor: UIColor = UIColor.convertUsingHexString(hexValue: "#D1D1D1")
    }
    
    struct Metrics {
        static let sideInset = 20.f
        static let topOffset = 20.f
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
    
    let postTitleTextField = UITextField().then {
        $0.placeholder = "제품명"
        $0.font = Fonts.guideLabel
        $0.tintColor = UIColor(named: K.Color.appColor)
    }
    
    let dividerLine_1 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let priceTextField = UITextField().then {
        $0.placeholder = "￦ 제품 가격"
        $0.font = Fonts.guideLabel
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.keyboardType = .numberPad
    }
    
    let slashLabel = UILabel().then {
        $0.text = "/"
        $0.textColor = UIColor(named: K.Color.appColor)
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    let gatheringPeopleTextField = UITextField().then {
        $0.placeholder = "인원(본인포함)"
        $0.font = Fonts.guideLabel
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.keyboardType = .numberPad
    }
    
    let peopleUnitLabel = UILabel().then {
        $0.text = "명"
        $0.textColor = .black
        $0.font = Fonts.guideLabel
    }
    
    let priceAndGatheringPeopleInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = 5
    }
    
    let dividerLine_2 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let shippingFeeTextField = UITextField().then {
        $0.placeholder = "￦ 배송비"
        $0.font = Fonts.guideLabel
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.keyboardType = .numberPad
    }
    
    let dividerLine_3 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let perPersonLabel = UILabel().then {
        $0.text = "1인당"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
        $0.textColor = UIColor.convertUsingHexString(hexValue: "#545454")
    }
    
    let pricePerPersonLabel = UILabel().then {
        $0.text = "0"
        $0.font = UIFont(name: K.Fonts.robotoBold, size: 26)
        $0.textColor = .black
    }
    
    let wonLabel = UILabel().then {
        $0.text = "원"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
        $0.textColor = UIColor.convertUsingHexString(hexValue: "#545454")
    }
    
    let perPersonPriceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillProportionally
        $0.spacing = 5
    }
    
    let referenceUrlTextField = UITextField().then {
        $0.placeholder = "상품 URL을 입력해주세요."
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.font = Fonts.guideLabel
        $0.addImage(direction: .Left, image: UIImage(systemName: "link")!, colorSeparator: .clear, colorBorder: .clear)
    }
    
    let dividerLine_4 = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let horizontalLine = UIView().then {
        $0.backgroundColor = Colors.dividerLineColor
    }
    
    let postDetailTextView = UITextView().then {
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.placeholder = Texts.textViewPlaceholder
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.font = Fonts.guideLabel
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
        contentView.addSubview(postTitleTextField)
        contentView.addSubview(dividerLine_1)
        
        [priceTextField, slashLabel, gatheringPeopleTextField, peopleUnitLabel].forEach {
            priceAndGatheringPeopleInfoStackView.addArrangedSubview($0)
        }
        contentView.addSubview(priceAndGatheringPeopleInfoStackView)
        
        contentView.addSubview(dividerLine_2)
        contentView.addSubview(shippingFeeTextField)
        contentView.addSubview(dividerLine_3)

        [perPersonLabel, pricePerPersonLabel, wonLabel].forEach {
            perPersonPriceStackView.addArrangedSubview($0)
        }
        contentView.addSubview(perPersonPriceStackView)

        contentView.addSubview(referenceUrlTextField)
        contentView.addSubview(dividerLine_4)
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
        
        postImagesCollectionView.snp.makeConstraints {
            $0.height.equalTo(135)
            $0.top.equalToSuperview().offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset - 5)
        }

        postTitleTextField.snp.makeConstraints {
            $0.top.equalTo(postImagesCollectionView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }

        dividerLine_1.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(postTitleTextField.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }

        priceAndGatheringPeopleInfoStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_1.snp.bottom).offset(Metrics.topOffset)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }
        
        dividerLine_2.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(priceAndGatheringPeopleInfoStackView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }

        shippingFeeTextField.snp.makeConstraints {
            $0.top.equalTo(dividerLine_2.snp.bottom).offset(Metrics.topOffset)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }
        
        dividerLine_3.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(shippingFeeTextField.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }

        perPersonPriceStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_3.snp.bottom).offset(Metrics.topOffset)
            $0.right.equalToSuperview().inset(Metrics.sideInset)
        }

        referenceUrlTextField.snp.makeConstraints {
            $0.top.equalTo(perPersonPriceStackView.snp.bottom).offset(Metrics.topOffset)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }
        
        dividerLine_4.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(referenceUrlTextField.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
        }
        
        horizontalLine.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.equalTo(dividerLine_4.snp.bottom).offset(Metrics.topOffset)
            $0.height.equalTo(250)
            $0.left.equalToSuperview().inset(Metrics.sideInset)
        }

        postDetailTextView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_4.snp.bottom).offset(Metrics.topOffset)
            $0.left.equalTo(horizontalLine.snp.right).offset(5)
            $0.right.equalToSuperview().inset(Metrics.sideInset)
            $0.height.equalTo(250)
        }
        
        doneButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview().inset(Metrics.sideInset)
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
        


        
        
        // Output
        
        
        
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
