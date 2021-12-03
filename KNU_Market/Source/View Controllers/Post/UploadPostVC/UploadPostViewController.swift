import UIKit
import SnapKit
import GMStepper

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
    
    lazy var postScrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.frame = self.view.bounds
        scrollView.contentSize = contentViewSize
        scrollView.clipsToBounds = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.autoresizingMask = .flexibleHeight
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.frame.size = contentViewSize
        return view
    }()
    
    let postTitleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "공구 제목"
        textField.font = Fonts.guideLabel
        textField.tintColor = UIColor(named: K.Color.appColor)
        return textField
    }()
    
    let dividerLineImageView_1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "line divider (gray)")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var postImagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 80, height: 80)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.register(
            AddPostImageCollectionViewCell.self,
            forCellWithReuseIdentifier: AddPostImageCollectionViewCell.cellId
        )
        cv.register(
            UserPickedPostImageCollectionViewCell.self,
            forCellWithReuseIdentifier: UserPickedPostImageCollectionViewCell.cellId
        )
        cv.showsHorizontalScrollIndicator = true
        cv.isScrollEnabled = true
        cv.alwaysBounceHorizontal = true
        cv.clipsToBounds = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    let dividerLineImageView_2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "line divider (gray)")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    
    let gatheringPeopleGuideLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.guideLabel
        label.text = "모집 인원 :"
        return label
    }()
    
    let totalGatheringPeopleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "2 명"
        return label
    }()
    
    lazy var gatheringPeopleStackView: UIStackView = {
        let stackView = UIStackView()
        [gatheringPeopleGuideLabel, totalGatheringPeopleLabel].forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 17
        return stackView
    }()
    
    let includeSelfLabel: UILabel = {
        let label = UILabel()
        label.text = "✻ 본인 포함"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .lightGray
        return label
    }()
    
    lazy var gatheringPeopleGuideStackView: UIStackView = {
        let stackView = UIStackView()
        [gatheringPeopleStackView, includeSelfLabel].forEach { stackView.addArrangedSubview($0) }
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    let gatheringPeopleStepper: GMStepper = {
        let stepper = GMStepper()
        stepper.value = 2
        stepper.minimumValue = 2
        stepper.maximumValue = 10
        stepper.stepValue = 1
        stepper.buttonsTextColor = .white
        stepper.buttonsBackgroundColor = UIColor(named: K.Color.appColor)!
        stepper.buttonsFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        stepper.labelFont = .systemFont(ofSize: 15)
        stepper.labelTextColor = UIColor(named:K.Color.appColor)!
        stepper.labelBackgroundColor = UIColor.systemGray6
        stepper.limitHitAnimationColor = .white
        stepper.cornerRadius = 5
        stepper.limitHitAnimationColor = .systemRed
        stepper.addTarget(
            self,
            action: #selector(pressedStepper),
            for: .valueChanged
        )
        return stepper
    }()

    lazy var locationPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        
        return pickerView
    }()
    
    let preferredLocationGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "거래 선호 장소 :"
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    lazy var tradeLocationTextField: UITextField = {
        let textField = UITextField()
        textField.text = "북문"
        textField.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textField.textAlignment = .right
        textField.borderStyle = .none
        textField.tintColor = .clear
        textField.inputView = locationPickerView
        return textField
    }()
    
    lazy var expandTextField: UITextField = {
        let textField = UITextField()
        textField.text = "▼"
        textField.textColor = UIColor(named: K.Color.appColor)!
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.textAlignment = .center
        textField.borderStyle = .none
        textField.tintColor = .clear
        textField.inputView = locationPickerView
        return textField
    }()
    
    let postDetailGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "공구 내용"
        label.font = Fonts.guideLabel
        return label
    }()
    
    lazy var postDetailTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.clipsToBounds = true
        textView.text = Texts.textViewPlaceholder
        textView.textColor = UIColor.lightGray
        textView.tintColor = UIColor(named: K.Color.appColor)
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    
    lazy var uploadPostBarButtonItem = UIBarButtonItem(
        title: "완료",
        style: .plain,
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
    
    override func setupActions() {
        super.setupActions()
    }
    
    //MARK: - Configuration
    
    private func configure() {
        title = "공구 올리기"
        viewModel.delegate = self
        createObserversForPresentingVerificationAlert()
        
        if editModel != nil { configurePageWithPriorData() }
    }
}
