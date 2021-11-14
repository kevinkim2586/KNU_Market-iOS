import UIKit
import SnapKit
import SDWebImage

class PostTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    
    private var viewModel: PostCellViewModel?
    
    //MARK: - Constants
    
    static let cellId: String = "PostTableViewCell"
    
    fileprivate struct Metrics {
        
        static let topOffSet: CGFloat = 15
        static let bottomOffSet: CGFloat = 15
        static let leftOffSet: CGFloat = 20
        static let rightOffSet: CGFloat = 20
        
        static let isGatheringLabelHeight: CGFloat = 20
    }
    
    //MARK: - UI
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
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
    
    lazy var isGatheringLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        label.textColor = UIColor.white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = Metrics.isGatheringLabelHeight / 2
        label.textAlignment = .center
        return label
    }()
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.peopleIcon)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let currentlyGatheredPeopleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15.0, weight: .medium)
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
        isGatheringLabel.text = nil
        currentlyGatheredPeopleLabel.text = nil
        locationLabel.text = nil
        dateLabel.text = nil
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        addSubview(postImageView)
        addSubview(dateLabel)
        addSubview(postTitleLabel)
        addSubview(isGatheringLabel)
        addSubview(personImageView)
        addSubview(currentlyGatheredPeopleLabel)
        addSubview(locationLabel)
    }
    
    private func setupConstraints() {
        
        postImageView.snp.makeConstraints { make in
            make.width.height.equalTo(90)
            make.left.equalToSuperview().offset(Metrics.leftOffSet)
            make.centerY.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.topOffSet)
            make.right.equalToSuperview().offset(-Metrics.rightOffSet)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(postImageView.snp.right).offset(Metrics.leftOffSet)
            make.top.equalToSuperview().offset(15)
            make.right.equalTo(dateLabel.snp.left).offset(-15)
        }
        
        isGatheringLabel.snp.makeConstraints { make in
            make.left.equalTo(postImageView.snp.right).offset(Metrics.leftOffSet)
            make.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
            make.height.equalTo(Metrics.isGatheringLabelHeight)
            make.width.equalTo(70)
        }
        
        personImageView.snp.makeConstraints { make in
            make.left.equalTo(isGatheringLabel.snp.right).offset(15)
            make.width.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
        }
        
        currentlyGatheredPeopleLabel.snp.makeConstraints { make in
            make.left.equalTo(personImageView.snp.right).offset(10)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-Metrics.rightOffSet)
            make.bottom.equalToSuperview().offset(-Metrics.bottomOffSet)
        }
    }
    
    //MARK: - Data Configuration

    func configure(with model: ItemListModel) {
        
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
            isGatheringLabel.text = "모집 완료"
            isGatheringLabel.backgroundColor = UIColor.lightGray
            currentlyGatheredPeopleLabel.isHidden = true
            personImageView.isHidden = true
        } else {
            isGatheringLabel.text = "모집 중"
            isGatheringLabel.backgroundColor = UIColor(named: K.Color.appColor)
            currentlyGatheredPeopleLabel.isHidden = false
            personImageView.isHidden = false
        }
    }
    
    private func configureCurrentlyGatheredPeopleLabel() {
        var currentNum = viewModel?.currentlyGatheredPeople ?? 1
        if viewModel?.currentlyGatheredPeople ?? 0 < 1 { currentNum = 1 }
        let total = viewModel?.totalGatheringPeople ?? 2

        currentlyGatheredPeopleLabel.text = "\(currentNum)" + "/" + "\(total) 명"
    }
    
    private func configureLocationLabel() {
        locationLabel.text = viewModel?.locationName ?? "-"
    }
    
    private func configureDateLabel() {
        dateLabel.text = viewModel?.date ?? "-\n-"
    }
}
