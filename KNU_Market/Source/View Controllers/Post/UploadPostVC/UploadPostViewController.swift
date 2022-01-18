import UIKit
import SnapKit
import GMStepper
import Then
import UITextView_Placeholder

class UploadPostViewController: BaseViewController {
    
    //MARK: - Properties
    
    var viewModel: UploadPostViewModel!
    var editModel: EditPostModel?
    
    //MARK: - Constants
    
    struct Texts {
        static let textViewPlaceholder: String = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.) \n\n 게시 가능 글 종류: \n- 배달음식 공구 \n- 온라인 쇼핑 공구 \n- 물물교환 및 나눔\n\n✻ 그 외 아래의 규칙을 위반할 시 게시물이 삭제되고 서비스 이용이 일정 기간 제한될 수 있습니다.\n- 음란물, 성적 수치심을 유발하는 내용\n- 욕설, 차별, 비하, 폭력 관련 내용을 포함하는 행위\n- 범죄, 불법 행위 등 법령을 위반하는 행위"
    }
    
    struct Fonts {
        static let guideLabel: UIFont = UIFont.systemFont(ofSize: 17, weight: .medium)
    }
    
    struct Metrics {
        static let basicInset: CGFloat = 15
    }
    
    //MARK: - UI
    
    lazy var contentViewSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    
    private lazy var postScrollView = UIScrollView(frame: .zero).then {
        $0.frame = self.view.bounds
        $0.contentSize = contentViewSize
        $0.clipsToBounds = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = true
        $0.autoresizingMask = .flexibleHeight
    }
    
    private lazy var contentView = UIView().then {
        $0.backgroundColor = .white
        $0.frame.size = contentViewSize
    }
    
    let postTitleTextField = UITextField().then {
        $0.placeholder = "공구 제목"
        $0.font = Fonts.guideLabel
        $0.tintColor = UIColor(named: K.Color.appColor)
    }
    
    private let dividerLineImageView_1 = UIImageView().then {
        $0.image = UIImage(named: "line divider (gray)")
        $0.clipsToBounds = true
        $0.contentMode = .scaleToFill
    }
    
    private let layout = UICollectionViewFlowLayout().then {
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
    
    private let dividerLineImageView_2 = UIImageView().then {
        $0.image = UIImage(named: "line divider (gray)")
        $0.clipsToBounds = true
        $0.contentMode = .scaleToFill
    }
    
    
    private let gatheringPeopleGuideLabel = UILabel().then {
        $0.font = Fonts.guideLabel
        $0.text = "모집 인원 :"
    }
    
    let totalGatheringPeopleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.text = "2 명"
    }
    
    private lazy var gatheringPeopleStackView = UIStackView().then { stackView in
        [gatheringPeopleGuideLabel, totalGatheringPeopleLabel].forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 17
    }
    
    private let includeSelfLabel = UILabel().then {
        $0.text = "✻ 본인 포함"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .lightGray
    }
    
    lazy var gatheringPeopleGuideStackView = UIStackView().then { stackView in
        [gatheringPeopleStackView, includeSelfLabel].forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
    }
    
    let gatheringPeopleStepper = GMStepper().then {
        $0.value = 2
        $0.minimumValue = 2
        $0.maximumValue = 10
        $0.stepValue = 1
        $0.buttonsTextColor = .white
        $0.buttonsBackgroundColor = UIColor(named: K.Color.appColor)!
        $0.buttonsFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.labelFont = .systemFont(ofSize: 15)
        $0.labelTextColor = UIColor(named:K.Color.appColor)!
        $0.labelBackgroundColor = UIColor.systemGray6
        $0.limitHitAnimationColor = .white
        $0.cornerRadius = 5
        $0.limitHitAnimationColor = .systemRed
        $0.addTarget(
            self,
            action: #selector(pressedStepper),
            for: .valueChanged
        )
    }

    lazy var locationPickerView = UIPickerView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .white
    }
    
    private let preferredLocationGuideLabel = UILabel().then {
        $0.text = "거래 선호 장소 :"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
    }
    
    lazy var tradeLocationTextField = UITextField().then {
        $0.text = "북문"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        $0.textAlignment = .right
        $0.borderStyle = .none
        $0.tintColor = .clear
        $0.inputView = locationPickerView
    }
    
    lazy var expandTextField = UITextField().then {
        $0.text = "▼"
        $0.textColor = UIColor(named: K.Color.appColor)!
        $0.font = UIFont.systemFont(ofSize: 22)
        $0.textAlignment = .center
        $0.borderStyle = .none
        $0.tintColor = .clear
        $0.inputView = locationPickerView
    }
    
    private let postDetailGuideLabel = UILabel().then {
        $0.text = "공구 내용"
        $0.font = Fonts.guideLabel
    }
    
    lazy var postDetailTextView = UITextView().then {
        $0.layer.borderWidth = 0.5
        $0.layer.cornerRadius = 5.0
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.clipsToBounds = true
        $0.textColor = .none
        $0.placeholder = Texts.textViewPlaceholder
        $0.placeholderColor = .lightGray
        $0.tintColor = UIColor(named: K.Color.appColor)
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var uploadPostBarButtonItem = UIBarButtonItem(
        title: "완료",
        style: .done,
        target: self,
        action: #selector(pressedUploadButton)
    )
    
    //MARK: - Initialization
    
    init(viewModel: UploadPostViewModel) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.viewModel = viewModel
    }
    
    init(viewModel: UploadPostViewModel, editModel: EditPostModel) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.viewModel = viewModel
        self.editModel = editModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.rightBarButtonItem = uploadPostBarButtonItem

//        view.addSubview(navigationBar)
        view.addSubview(postScrollView)
        postScrollView.addSubview(contentView)
        contentView.addSubview(postTitleTextField)
        contentView.addSubview(dividerLineImageView_1)
        contentView.addSubview(postImagesCollectionView)
        contentView.addSubview(dividerLineImageView_2)
        contentView.addSubview(gatheringPeopleGuideStackView)
        contentView.addSubview(gatheringPeopleStepper)
        contentView.addSubview(preferredLocationGuideLabel)
        contentView.addSubview(tradeLocationTextField)
        contentView.addSubview(expandTextField)
        contentView.addSubview(postDetailGuideLabel)
        contentView.addSubview(postDetailTextView)
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
    
        postTitleTextField.snp.makeConstraints {
            $0.top.left.right.equalTo(Metrics.basicInset)
            $0.height.greaterThanOrEqualTo(40)
        }
        
        dividerLineImageView_1.snp.makeConstraints {
            $0.top.equalTo(postTitleTextField.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }

        postImagesCollectionView.snp.makeConstraints {
            $0.height.equalTo(135)
            $0.top.equalTo(dividerLineImageView_1.snp.bottom).offset(10)
            $0.width.equalTo(view.frame.size.width - 20)
        }

        dividerLineImageView_2.snp.makeConstraints {
            $0.top.equalTo(postImagesCollectionView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        gatheringPeopleGuideStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLineImageView_2.snp.bottom).offset(Metrics.basicInset)
            $0.left.equalToSuperview().inset(Metrics.basicInset)
        }

        gatheringPeopleStepper.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(30)
            $0.top.equalTo(dividerLineImageView_2.snp.bottom).offset(20)
            $0.right.equalToSuperview().offset(-20)
        }

        preferredLocationGuideLabel.snp.makeConstraints {
            $0.top.equalTo(gatheringPeopleGuideStackView.snp.bottom).offset(30)
            $0.left.equalToSuperview().inset(Metrics.basicInset)
        }

        expandTextField.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(gatheringPeopleStepper.snp.bottom).offset(36)
        }

        tradeLocationTextField.snp.makeConstraints {
            $0.top.equalTo(gatheringPeopleStepper.snp.bottom).offset(41)
            $0.right.equalTo(expandTextField.snp.left).offset(-7)
        }

        postDetailGuideLabel.snp.makeConstraints {
            $0.top.equalTo(preferredLocationGuideLabel.snp.bottom).offset(35)
            $0.left.equalToSuperview().inset(Metrics.basicInset)
        }

        postDetailTextView.snp.makeConstraints {
            $0.top.equalTo(postDetailGuideLabel.snp.bottom).offset(Metrics.basicInset)
            $0.left.equalToSuperview().offset(Metrics.basicInset)
            $0.right.equalToSuperview().offset(-Metrics.basicInset)
            $0.bottom.equalToSuperview().offset(-Metrics.basicInset)
            $0.height.equalTo(300)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    //MARK: - Configuration
    
    private func configure() {
        title = "공구 올리기"
        viewModel.delegate = self
        createObserversForPresentingVerificationAlert()
        
        if editModel != nil { configurePageWithPriorData() }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct UploadPostVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        UploadPostViewController(
           viewModel: UploadPostViewModel(
               postManager: PostManager(),
               mediaManager: MediaManager()
           )
        ).toPreview()
    }
}
#endif
