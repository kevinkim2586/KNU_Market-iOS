import UIKit
import SnapKit
import Then
import SDWebImage

class PostTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    private var viewModel: PostCellViewModel?
    
    //MARK: - Constants
    
    static let cellId: String = "PostTableViewCell"
    
    fileprivate struct Metrics {
        
        static let topOffSet: CGFloat       = 15
        static let bottomOffSet: CGFloat    = 15
        static let leftOffSet: CGFloat      = 20
        static let rightOffSet: CGFloat     = 20
        
        static let isGatheringLabelHeight: CGFloat = 27
    }
    
    //MARK: - UI
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(named: K.Images.defaultItemImage)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.85
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.numberOfLines = 2
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "singlePersonIcon")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let gatheringStatusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
    }
    
    lazy var gatheringStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 7
        [personImageView, gatheringStatusLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    let gatherDoneLabel = UILabel().then {
        $0.text = "모집완료"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
    }
    
    let gatheringView = UIView().then {
        $0.layer.cornerRadius = Metrics.isGatheringLabelHeight / 2
        $0.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
        return label
    }()
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        postTitleLabel.text = nil
        gatheringStatusLabel.text = nil
        priceLabel.text = nil
        dateLabel.text = nil
        gatheringView.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {

        
        
        addSubview(postImageView)
        addSubview(dateLabel)
        addSubview(postTitleLabel)
        
        
    
        gatheringView.addSubview(gatheringStackView)
        gatheringView.addSubview(gatherDoneLabel)
        addSubview(gatheringView)
        
        
        addSubview(priceLabel)
    }
    
    private func setupConstraints() {
        
        postImageView.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.left.equalToSuperview().offset(Metrics.leftOffSet)
            $0.centerY.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Metrics.topOffSet)
            $0.right.equalToSuperview().offset(-Metrics.rightOffSet)
        }
        
        postTitleLabel.snp.makeConstraints {
            $0.left.equalTo(postImageView.snp.right).offset(Metrics.leftOffSet)
            $0.top.equalToSuperview().offset(15)
            $0.right.equalTo(dateLabel.snp.left).offset(-15)
        }
        
        gatheringView.snp.makeConstraints {
            $0.width.equalTo(67)
            $0.height.equalTo(27)
            $0.left.equalTo(postImageView.snp.right).offset(Metrics.leftOffSet)
            $0.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
        }
        
        gatheringStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        gatherDoneLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.right.equalToSuperview().offset(-Metrics.rightOffSet)
            $0.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
        }
    }
    
    //MARK: - Data Configuration

    func configure(with model: PostListModel) {
        
        self.viewModel = PostCellViewModel(model: model)
        
        configurePostTitleLabel()
        configurePostImageView()
        configureGatheringLabel()
        configureCurrentlyGatheredPeopleLabel()
        configureLocationLabel()
        configureDateLabel()
    }
    
    private func configurePostTitleLabel() {
        postTitleLabel.text = viewModel?.title ?? ""
    }
    
    private func configurePostImageView() {
        
        if let imageUrl = viewModel?.imageURL {
            postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            postImageView.sd_setImage(
                with: imageUrl,
                placeholderImage: UIImage(named: K.Images.defaultItemImage),
                options: .continueInBackground,
                completed: nil
            )
        } else { postImageView.image = UIImage(named: K.Images.defaultItemImage) }
    }
    
    private func configureGatheringLabel() {
        
        if viewModel?.isCompletelyDone ?? false {
            gatherDoneLabel.isHidden = false
            gatheringView.backgroundColor = UIColor.lightGray
            gatheringStatusLabel.isHidden = true
            personImageView.isHidden = true
            
        } else {
            gatherDoneLabel.isHidden = true
            gatheringStatusLabel.isHidden = false
            personImageView.isHidden = false
        }
    }
    
    private func configureCurrentlyGatheredPeopleLabel() {
        var currentNum = viewModel?.currentlyGatheredPeople ?? 1
        if viewModel?.currentlyGatheredPeople ?? 0 < 1 { currentNum = 1 }
        let total = viewModel?.totalGatheringPeople ?? 2
        
        gatheringStatusLabel.text = "\(currentNum)/\(total)"
    }
    
    private func configureLocationLabel() {
        priceLabel.text = "\(viewModel?.price)"
    }
    
    private func configureDateLabel() {
        dateLabel.text = viewModel?.date ?? "-\n-"
    }
}
