import UIKit
import SnapKit
import RxSwift
import ReactorKit

class MyPageTableViewCell: UITableViewCell, View {
    
    typealias Reactor = MyPageCellReactor
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - Constants
    
    static let cellId: String = "MyPageTableViewCell"
    
    fileprivate struct Metrics {
        static let notificationBadgeSize: CGFloat = 10
    }
    
    //MARK: - UI
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    let settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    let notificationBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metrics.notificationBadgeSize / 2
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationBadgeImageView.isHidden = true
    }
    
    //MARK: - Configuration
    
    func setupLayout() {
        accessoryType = .disclosureIndicator
        contentView.addSubview(leftImageView)
        contentView.addSubview(settingsTitleLabel)
        contentView.addSubview(notificationBadgeImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        
        leftImageView.snp.makeConstraints {
            $0.width.height.equalTo(25)
            $0.left.equalTo(self.snp.left).offset(20)
            $0.top.bottom.equalToSuperview()
        }
    
        settingsTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.snp.centerY)
            $0.left.equalTo(leftImageView.snp.right).offset(12)
        }
        
        notificationBadgeImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.notificationBadgeSize)
            $0.centerY.equalTo(self.snp.centerY)
            $0.left.equalTo(settingsTitleLabel.snp.right).offset(10)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: MyPageCellReactor) {
        self.leftImageView.image = reactor.currentState.leftImage
        self.settingsTitleLabel.text = reactor.currentState.title
        self.notificationBadgeImageView.isHidden = reactor.currentState.isNotificationBadgeHidden
    }
}
